#!/usr/bin/env python3
"""Robotinics Rev. 4 serial simulator.

Simulates the Body Controller (Arduino Mega) and MCabeca protocol over a
pseudo-terminal, allowing the real Raspberry Gateway to be tested without
physical hardware.
"""

import argparse
import json
import os
import pty
import select
import signal
import sys
import time
from dataclasses import dataclass, field


PROMPT = "$>"


@dataclass
class HeadState:
    x: int = 90
    y: int = 45
    distance_cm: float = 120.0
    laser: bool = False
    led_blue: bool = False
    led_green: bool = False
    led_red: bool = False
    eyes: bool = False
    light_auto: bool = False


@dataclass
class BodyState:
    motion: str = "STOPPED"
    ultra_re_cm: float = 120.0
    ultra_front_cm: float = 120.0
    ultra_head_cm: float = 120.0
    current_a: float = 0.0
    gas_status: str = "Nao detectado sensor fumaça"
    safety_last_stop: str = "none"
    capabilities: list = field(default_factory=lambda: [
        "MOTION",
        "SERVOS",
        "ULTRASONIC",
        "ANALOG_SENSORS",
        "GPS",
        "LCD",
        "MCABECA_BRIDGE",
        "SAFETY_WATCHDOG",
    ])


class RobotinicsSimulator:
    def __init__(self, collision_margin_cm=20.0, watchdog_s=3.0, motion_timeout_s=30.0):
        self.body = BodyState()
        self.head = HeadState()
        self.collision_margin_cm = float(collision_margin_cm)
        self.watchdog_s = float(watchdog_s)
        self.motion_timeout_s = float(motion_timeout_s)
        self.motion_started = None
        self.last_control_activity = time.monotonic()
        self.drop_responses = False
        self.disconnect = False

    def _stop(self, reason):
        self.body.motion = "STOPPED"
        self.body.safety_last_stop = reason
        self.motion_started = None
        return [f"SAFETY:STOP:{reason}"]

    def tick(self):
        if self.body.motion == "STOPPED":
            return []
        now = time.monotonic()
        if self.motion_started is not None and now - self.motion_started >= self.motion_timeout_s:
            return self._stop("motion_timeout")
        if now - self.last_control_activity >= self.watchdog_s:
            return self._stop("control_watchdog")
        if self.body.motion == "FRENTE" and self.body.ultra_front_cm < self.collision_margin_cm:
            return self._stop("front_obstacle")
        if self.body.motion == "RE" and self.body.ultra_re_cm < self.collision_margin_cm:
            return self._stop("rear_obstacle")
        return []

    def set_sensor(self, name, value):
        mapping = {
            "ultra": "ultra_re_cm",
            "ultra1": "ultra_front_cm",
            "ultra2": "ultra_head_cm",
            "current": "current_a",
        }
        if name not in mapping:
            raise ValueError(f"unknown sensor: {name}")
        setattr(self.body, mapping[name], float(value))

    def set_fault(self, name, enabled=True):
        if name == "drop_responses":
            self.drop_responses = bool(enabled)
        elif name == "disconnect":
            self.disconnect = bool(enabled)
        else:
            raise ValueError(f"unknown fault: {name}")

    def _motion(self, command):
        self.body.motion = command
        now = time.monotonic()
        self.motion_started = now
        self.last_control_activity = now
        return []

    def _head_command(self, inner):
        if inner in {"DIST", "ULTRA"}:
            return [f"MCAB:DIST:{self.head.distance_cm:.1f}"]
        if inner == "GETPOS":
            return [f"MCAB:POS:{self.head.x},{self.head.y}"]
        if inner == "CENTER":
            self.head.x, self.head.y = 90, 45
            return [f"MCAB:POS:{self.head.x},{self.head.y}"]
        if inner.startswith("POINT:") or inner.startswith("POINT="):
            raw = inner.split(inner[5], 1)[1]
            x, y = (int(v) for v in raw.split(",", 1))
            self.head.x, self.head.y = x, y
            return [f"MCAB:POS:{x},{y}"]
        if inner == "LASERON":
            self.head.laser = True
            return ["MCAB:OK:LASER=ON"]
        if inner == "LASEROFF":
            self.head.laser = False
            return ["MCAB:OK:LASER=OFF"]

        bool_map = {
            "LEDAZUL=": "led_blue",
            "LEDVERDE=": "led_green",
            "LEDVERMELHO=": "led_red",
            "OLHOS=": "eyes",
            "LIGHTAUTO=": "light_auto",
        }
        for prefix, attr in bool_map.items():
            if inner.startswith(prefix):
                enabled = inner[len(prefix):].upper() == "ON"
                setattr(self.head, attr, enabled)
                return [f"MCAB:OK:{prefix[:-1]}={'ON' if enabled else 'OFF'}"]

        if inner == "VER":
            return ["MCAB:VERSION:1.2"]
        if inner in {"MAN", "TESTE", "SCANNING"}:
            return [f"MCAB:OK:{inner}"]
        return ["MCAB:ERR:UNKNOWN_COMMAND"]

    def command(self, raw):
        command = raw.strip()
        if not command:
            return []

        self.last_control_activity = time.monotonic()

        if command == "PING":
            return ["PONG", PROMPT]
        if command == "PARA":
            self._stop("command")
            return [PROMPT]
        if command in {"FRENTE", "RE", "GESQ", "GDIR"}:
            self._motion(command)
            return [PROMPT]
        if command == "IDENTIFY":
            return ["RBT:IDENTIFY:BODY:MEGA2560:1.3", PROMPT]
        if command == "CAPABILITIES":
            return [*(f"RBT:CAP:{cap}" for cap in self.body.capabilities), PROMPT]
        if command == "SAFETY":
            active = "ACTIVE" if self.body.motion != "STOPPED" else "STOPPED"
            return [
                f"SAFETY:MOTION:{active}",
                f"SAFETY:LAST_STOP:{self.body.safety_last_stop}",
                PROMPT,
            ]
        if command == "ULTRA":
            return [f"Cent: {self.body.ultra_re_cm:.2f}, Pol. : {self.body.ultra_re_cm / 2.54:.2f}", PROMPT]
        if command == "ULTRA1":
            return [f"Cent: {self.body.ultra_front_cm:.2f}, Pol. : {self.body.ultra_front_cm / 2.54:.2f}", PROMPT]
        if command == "ULTRA2":
            return [f"Cent: {self.body.ultra_head_cm:.2f}, Pol. : {self.body.ultra_head_cm / 2.54:.2f}", PROMPT]
        if command == "CORR":
            return [f"Corrente:{self.body.current_a:.2f}", PROMPT]
        if command == "GAS":
            return [self.body.gas_status, PROMPT]
        if command.startswith("MCAB:"):
            return [*self._head_command(command[5:]), PROMPT]

        if command.startswith((
            "GCABECAESQ=", "GCABECADIR=", "GBDIR=", "GBESQ=",
            "GPGARRADIR=", "GPGARRAESQ=", "GPPUNHOESQ=", "GPPUNHODIR=",
            "MSG1:", "MSG2:", "SETMONITOR="
        )):
            return [PROMPT]

        if command in {"CLS", "LCDCLEAR", "ACEL", "GPS", "MAN", "VER", "TESTE"}:
            return [PROMPT]

        return ["Comando não reconhecido!", PROMPT]

    def snapshot(self):
        return {
            "body": {
                "motion": self.body.motion,
                "ultra_re_cm": self.body.ultra_re_cm,
                "ultra_front_cm": self.body.ultra_front_cm,
                "ultra_head_cm": self.body.ultra_head_cm,
                "current_a": self.body.current_a,
                "safety_last_stop": self.body.safety_last_stop,
            },
            "head": vars(self.head).copy(),
            "faults": {
                "drop_responses": self.drop_responses,
                "disconnect": self.disconnect,
            },
        }


def run_pty(sim):
    master_fd, slave_fd = pty.openpty()
    slave_name = os.ttyname(slave_fd)
    print(slave_name, flush=True)

    buffer = b""
    running = True

    def stop_handler(_signum, _frame):
        nonlocal running
        running = False

    signal.signal(signal.SIGTERM, stop_handler)
    signal.signal(signal.SIGINT, stop_handler)

    while running:
        for event in sim.tick():
            if not sim.drop_responses and not sim.disconnect:
                os.write(master_fd, (event + "\n").encode())

        ready, _, _ = select.select([master_fd], [], [], 0.05)
        if not ready:
            continue

        try:
            chunk = os.read(master_fd, 1024)
        except OSError:
            break
        if not chunk:
            break

        buffer += chunk
        while b"\n" in buffer:
            raw, buffer = buffer.split(b"\n", 1)
            command = raw.decode("utf-8", errors="replace").strip("\r")
            responses = sim.command(command)
            if sim.drop_responses or sim.disconnect:
                continue
            for line in responses:
                os.write(master_fd, (line + "\n").encode())

    os.close(master_fd)
    os.close(slave_fd)


def main():
    parser = argparse.ArgumentParser(description="Robotinics serial simulator")
    parser.add_argument("--watchdog", type=float, default=3.0)
    parser.add_argument("--motion-timeout", type=float, default=30.0)
    parser.add_argument("--collision-margin", type=float, default=20.0)
    parser.add_argument("--snapshot", action="store_true")
    args = parser.parse_args()

    sim = RobotinicsSimulator(
        collision_margin_cm=args.collision_margin,
        watchdog_s=args.watchdog,
        motion_timeout_s=args.motion_timeout,
    )

    if args.snapshot:
        print(json.dumps(sim.snapshot(), indent=2))
        return 0

    run_pty(sim)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

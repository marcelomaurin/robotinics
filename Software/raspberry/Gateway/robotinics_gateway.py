#!/usr/bin/env python3
import json
import logging
import os
import queue
import re
import signal
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import sys
import threading
import time
import uuid
from collections import deque
from pathlib import Path

import serial

LOG = logging.getLogger("robotinics-gateway")
RUN = threading.Event()
RUN.set()

PORT = os.getenv("ROBOTINICS_SERIAL_PORT", "/dev/ttyACM0")
BAUD = int(os.getenv("ROBOTINICS_SERIAL_BAUD", "115200"))
STATE_DIR = Path(os.getenv("ROBOTINICS_STATE_PATH", "/var/lib/robotinics"))
STATE_FILE = STATE_DIR / "gateway-state.json"
HISTORY_FILE = STATE_DIR / "gateway-history.jsonl"
LISTEN_HOST = os.getenv("ROBOTINICS_GATEWAY_HOST", "127.0.0.1")
LISTEN_PORT = int(os.getenv("ROBOTINICS_GATEWAY_PORT", "8765"))
DEFAULT_TIMEOUT = float(os.getenv("ROBOTINICS_COMMAND_TIMEOUT", "5"))
HISTORY_SIZE = int(os.getenv("ROBOTINICS_HISTORY_SIZE", "200"))
HEARTBEAT_INTERVAL = float(os.getenv("ROBOTINICS_HEARTBEAT_INTERVAL", "1.0"))
HEARTBEAT_TIMEOUT = float(os.getenv("ROBOTINICS_HEARTBEAT_TIMEOUT", "2.0"))

ANGLE_PREFIXES = (
    "GCABECAESQ=", "GPPUNHOESQ=", "GPPUNHODIR=", "GCABECADIR=",
    "GBDIR=", "GBESQ=", "GPGARRADIR=", "GPGARRAESQ="
)
EXACT_COMMANDS = {
    "RE", "PARA", "FRENTE", "GESQ", "GDIR", "CLS", "GPS", "ACEL",
    "ULTRA", "ULTRA1", "ULTRA2", "GAS", "CORR", "MAN", "VER", "TESTE",
    "LCDCLEAR", "PING", "SAFETY", "IDENTIFY", "CAPABILITIES"
}
MCAB_EXACT = {
    "DIST", "GETPOS", "CENTER", "LASERON", "LASEROFF", "SCANNING",
    "VER", "MAN", "ULTRA", "TESTE"
}
MCAB_BOOL_PREFIXES = (
    "LEDAZUL=", "LEDVERDE=", "LEDVERMELHO=", "OLHOS=", "LIGHTAUTO="
)


class RobotState:
    def __init__(self):
        self.lock = threading.RLock()
        self.data = {
            "connected": False,
            "serial_port": PORT,
            "serial_baud": BAUD,
            "last_seen": None,
            "last_line": None,
            "active_request_id": None,
            "head": {
                "x": None,
                "y": None,
                "distance_cm": None,
                "laser": None,
                "led_blue": None,
                "led_green": None,
                "led_red": None,
                "eyes": None,
                "light_auto": None,
            },
            "sensors": {
                "ultra_cm": None,
                "ultra1_cm": None,
                "ultra2_cm": None,
                "gas": None,
                "current": None,
            },
            "motion": {
                "last_command": None,
                "stopped": None,
                "safety_stop_reason": None,
                "last_heartbeat": None,
            },
            "faults": [],
            "last_error": None,
        }

    def update(self, **kwargs):
        with self.lock:
            self.data.update(kwargs)
            self._save()

    def parse_line(self, line):
        now = time.time()
        with self.lock:
            self.data["last_seen"] = now
            self.data["last_line"] = line

            if line.startswith("MCAB:DIST:"):
                try:
                    self.data["head"]["distance_cm"] = float(line.split(":", 2)[2])
                except ValueError:
                    pass
            elif line.startswith("MCAB:POS:"):
                try:
                    xy = line.split(":", 2)[2].split(",", 1)
                    self.data["head"]["x"] = int(xy[0])
                    self.data["head"]["y"] = int(xy[1])
                except (ValueError, IndexError):
                    pass
            elif line.startswith("MCAB:OK:"):
                payload = line[8:]
                if "=" in payload:
                    name, value = payload.split("=", 1)
                    state = value.upper() == "ON"
                    mapping = {
                        "LASER": "laser",
                        "LEDAZUL": "led_blue",
                        "LEDVERDE": "led_green",
                        "LEDVERMELHO": "led_red",
                        "OLHOS": "eyes",
                        "LIGHTAUTO": "light_auto",
                    }
                    if name in mapping:
                        self.data["head"][mapping[name]] = state
            elif line.startswith("RBT:IDENTIFY:"):
                parts = line.split(":")
                if len(parts) >= 5:
                    self.data["device"] = {
                        "role": parts[2],
                        "board": parts[3],
                        "version": parts[4],
                    }
            elif line.startswith("RBT:CAP:"):
                capability = line.split(":", 2)[2]
                caps = self.data.setdefault("capabilities", [])
                if capability not in caps:
                    caps.append(capability)
            elif line.startswith("SAFETY:STOP:"):
                reason = line.split(":", 2)[2]
                self.data["motion"]["stopped"] = True
                self.data["motion"]["safety_stop_reason"] = reason
                self._fault("safety_stop", line)
            elif line.startswith("SAFETY:MOTION:"):
                self.data["motion"]["stopped"] = line.endswith(":STOPPED")
            elif line.startswith("SAFETY:LAST_STOP:"):
                self.data["motion"]["safety_stop_reason"] = line.split(":", 2)[2]
            elif "Colisao eminente" in line:
                self._fault("collision_warning", line)
            elif line.lower().startswith("erro") or "ERR:" in line:
                self._fault("device_error", line)

            self._save()

    def note_command(self, command):
        with self.lock:
            if command in {"PARA"}:
                self.data["motion"]["stopped"] = True
            elif command in {"FRENTE", "RE", "GESQ", "GDIR"}:
                self.data["motion"]["stopped"] = False
            if command == "PING":
                self.data["motion"]["last_heartbeat"] = time.time()
            elif command != "SAFETY":
                self.data["motion"]["last_command"] = command
            self._save()

    def _fault(self, code, detail):
        item = {"timestamp": time.time(), "code": code, "detail": detail}
        self.data["faults"].append(item)
        self.data["faults"] = self.data["faults"][-20:]

    def snapshot(self):
        with self.lock:
            return json.loads(json.dumps(self.data))

    def _save(self):
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        tmp = STATE_FILE.with_suffix(".tmp")
        tmp.write_text(json.dumps(self.data, ensure_ascii=False, indent=2))
        tmp.replace(STATE_FILE)


class Request:
    def __init__(self, command, timeout, internal=False):
        self.id = str(uuid.uuid4())
        self.command = command
        self.timeout = timeout
        self.created_at = time.time()
        self.started_at = None
        self.finished_at = None
        self.lines = []
        self.ok = False
        self.error = None
        self.done = threading.Event()
        self.internal = internal

    def result(self):
        return {
            "request_id": self.id,
            "command": self.command,
            "ok": self.ok,
            "error": self.error,
            "lines": list(self.lines),
            "created_at": self.created_at,
            "started_at": self.started_at,
            "finished_at": self.finished_at,
        }


def _parse_angle(value):
    try:
        n = int(value)
    except ValueError:
        raise ValueError("angle must be integer")
    if not 0 <= n <= 180:
        raise ValueError("angle out of range 0..180")
    return n


def validate_command(command):
    command = command.strip()
    if not command or len(command) > 96:
        raise ValueError("invalid command length")
    if "\r" in command or "\n" in command:
        raise ValueError("line breaks are not allowed")

    if command in EXACT_COMMANDS:
        return command

    if command.startswith("SETMONITOR="):
        value = command.split("=", 1)[1].upper()
        if value not in {"ON", "OFF"}:
            raise ValueError("SETMONITOR accepts ON/OFF")
        return "SETMONITOR=" + value

    for prefix in ANGLE_PREFIXES:
        if command.startswith(prefix):
            value = _parse_angle(command[len(prefix):])
            return prefix + str(value)

    if command.startswith("MSG1:") or command.startswith("MSG2:"):
        text = command.split(":", 1)[1]
        if not text or len(text) > 48:
            raise ValueError("LCD text must have 1..48 characters")
        return command

    if command.startswith("MCAB:"):
        inner = command[5:]
        if inner in MCAB_EXACT:
            return command

        if inner.startswith("POINT:") or inner.startswith("POINT="):
            args = inner.split(inner[5], 1)[1].split(",", 1)
            if len(args) != 2:
                raise ValueError("POINT requires x,y")
            x = _parse_angle(args[0])
            y = _parse_angle(args[1])
            return f"MCAB:POINT:{x},{y}"

        for prefix in MCAB_BOOL_PREFIXES:
            if inner.startswith(prefix):
                value = inner[len(prefix):].upper()
                if value not in {"ON", "OFF"}:
                    raise ValueError(prefix + " accepts ON/OFF")
                return "MCAB:" + prefix + value

        raise ValueError("MCabeca command is not catalogued")

    raise ValueError("command is not catalogued")


class Gateway:
    def __init__(self):
        self.state = RobotState()
        self.command_queue = queue.Queue(maxsize=100)
        self.history = deque(maxlen=HISTORY_SIZE)
        self.serial_lock = threading.Lock()
        self.serial_obj = None
        self.active = None
        self.active_lock = threading.RLock()
        self.reader_thread = None
        self.worker_thread = None
        self.heartbeat_thread = None

    def start(self):
        self.reader_thread = threading.Thread(target=self._serial_loop, name="serial-reader", daemon=True)
        self.worker_thread = threading.Thread(target=self._command_loop, name="command-worker", daemon=True)
        self.heartbeat_thread = threading.Thread(target=self._heartbeat_loop, name="safety-heartbeat", daemon=True)
        self.reader_thread.start()
        self.worker_thread.start()
        self.heartbeat_thread.start()

    def stop(self):
        RUN.clear()
        with self.serial_lock:
            if self.serial_obj:
                try:
                    self.serial_obj.close()
                except Exception:
                    pass
                self.serial_obj = None

    def submit(self, command, timeout=None, internal=False):
        command = validate_command(command)
        req = Request(command, float(timeout or DEFAULT_TIMEOUT), internal=internal)
        try:
            self.command_queue.put(req, timeout=1)
        except queue.Full:
            raise RuntimeError("command queue full")
        return req

    def _open_serial(self):
        with self.serial_lock:
            if self.serial_obj and self.serial_obj.is_open:
                return self.serial_obj
            self.serial_obj = serial.Serial(PORT, BAUD, timeout=0.25, write_timeout=1)
            self.serial_obj.reset_input_buffer()
            self.state.update(connected=True, last_error=None)
            LOG.info("serial connected: %s @ %d", PORT, BAUD)
            return self.serial_obj

    def _serial_loop(self):
        while RUN.is_set():
            try:
                ser = self._open_serial()
                raw = ser.readline()
                if not raw:
                    continue
                line = raw.decode("utf-8", errors="replace").strip()
                if not line:
                    continue

                LOG.info("mega: %s", line)
                self.state.parse_line(line)

                with self.active_lock:
                    req = self.active
                    if req:
                        if line == "$>":
                            req.ok = True
                            req.finished_at = time.time()
                            req.done.set()
                        else:
                            req.lines.append(line)
            except serial.SerialException as exc:
                LOG.warning("serial unavailable: %s", exc)
                self.state.update(connected=False, last_error=str(exc))
                with self.serial_lock:
                    if self.serial_obj:
                        try:
                            self.serial_obj.close()
                        except Exception:
                            pass
                        self.serial_obj = None
                time.sleep(2)
            except Exception as exc:
                LOG.exception("serial reader error: %s", exc)
                self.state.update(last_error=str(exc))
                time.sleep(1)

    def _heartbeat_loop(self):
        while RUN.is_set():
            time.sleep(max(0.2, HEARTBEAT_INTERVAL))
            if not RUN.is_set():
                break

            snapshot = self.state.snapshot()
            moving = snapshot.get("motion", {}).get("stopped") is False
            connected = snapshot.get("connected") is True

            if not moving or not connected:
                continue

            # Nao interfere em uma requisicao em andamento nem acumula heartbeat.
            with self.active_lock:
                busy = self.active is not None
            if busy or not self.command_queue.empty():
                continue

            try:
                self.submit("PING", HEARTBEAT_TIMEOUT, internal=True)
            except Exception as exc:
                LOG.warning("heartbeat submit failed: %s", exc)

    def _command_loop(self):
        while RUN.is_set():
            try:
                req = self.command_queue.get(timeout=0.5)
            except queue.Empty:
                continue

            try:
                req.started_at = time.time()
                with self.active_lock:
                    self.active = req
                    self.state.update(active_request_id=req.id)

                ser = self._open_serial()
                payload = (req.command + "\n").encode("utf-8")
                with self.serial_lock:
                    ser.write(payload)
                    ser.flush()

                self.state.note_command(req.command)

                if not req.done.wait(req.timeout):
                    req.error = "timeout waiting for device prompt"
                    req.finished_at = time.time()
                    req.ok = False
                    req.done.set()
            except Exception as exc:
                req.error = str(exc)
                req.finished_at = time.time()
                req.ok = False
                req.done.set()
            finally:
                with self.active_lock:
                    if self.active is req:
                        self.active = None
                        self.state.update(active_request_id=None)
                result = req.result()
                if not req.internal:
                    self.history.append(result)
                    self._append_history(result)
                self.command_queue.task_done()

    def _append_history(self, item):
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        with HISTORY_FILE.open("a", encoding="utf-8") as fp:
            fp.write(json.dumps(item, ensure_ascii=False) + "\n")

    def status(self):
        return {
            "gateway": {
                "serial_port": PORT,
                "serial_baud": BAUD,
                "listen": f"http://{LISTEN_HOST}:{LISTEN_PORT}",
                "queue_size": self.command_queue.qsize(),
                "heartbeat_interval": HEARTBEAT_INTERVAL,
            },
            "state": self.state.snapshot(),
        }


GATEWAY = Gateway()


class Handler(BaseHTTPRequestHandler):
    server_version = "RobotinicsGateway/1.0"

    def log_message(self, fmt, *args):
        LOG.info("api: " + fmt, *args)

    def _json(self, status, obj):
        data = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def _read_json(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length <= 0 or length > 16384:
            raise ValueError("invalid content length")
        raw = self.rfile.read(length)
        return json.loads(raw.decode("utf-8"))

    def do_GET(self):
        if self.path == "/v1/ping":
            self._json(200, {"ok": True, "pong": time.time()})
        elif self.path == "/v1/state":
            self._json(200, {"ok": True, **GATEWAY.status()})
        elif self.path == "/v1/catalog":
            self._json(200, {
                "ok": True,
                "exact": sorted(EXACT_COMMANDS),
                "angle_prefixes": ANGLE_PREFIXES,
                "mcab_exact": sorted(MCAB_EXACT),
                "mcab_bool_prefixes": MCAB_BOOL_PREFIXES,
            })
        elif self.path.startswith("/v1/history"):
            limit = 20
            if "?" in self.path:
                try:
                    query = self.path.split("?", 1)[1]
                    for item in query.split("&"):
                        if item.startswith("limit="):
                            limit = int(item.split("=", 1)[1])
                except ValueError:
                    limit = 20
            limit = max(1, min(limit, HISTORY_SIZE))
            self._json(200, {"ok": True, "history": list(GATEWAY.history)[-limit:]})
        else:
            self._json(404, {"ok": False, "error": "not found"})

    def do_POST(self):
        if self.path != "/v1/command":
            self._json(404, {"ok": False, "error": "not found"})
            return

        try:
            payload = self._read_json()
            req = GATEWAY.submit(payload.get("command", ""), payload.get("timeout"))
            if not req.done.wait(req.timeout + 1.0):
                self._json(504, {
                    "ok": False,
                    "request_id": req.id,
                    "error": "gateway wait timeout"
                })
            else:
                result = req.result()
                self._json(200 if result["ok"] else 504, result)
        except (ValueError, TypeError, json.JSONDecodeError) as exc:
            self._json(400, {"ok": False, "error": str(exc)})
        except RuntimeError as exc:
            self._json(503, {"ok": False, "error": str(exc)})
        except Exception as exc:
            LOG.exception("api error: %s", exc)
            self._json(500, {"ok": False, "error": str(exc)})


def stop_handler(signum, frame):
    RUN.clear()
    GATEWAY.stop()


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    signal.signal(signal.SIGTERM, stop_handler)
    signal.signal(signal.SIGINT, stop_handler)

    GATEWAY.start()
    with ThreadingHTTPServer((LISTEN_HOST, LISTEN_PORT), Handler) as server:
        server.timeout = 0.5
        LOG.info("local HTTP API listening on http://%s:%d", LISTEN_HOST, LISTEN_PORT)
        while RUN.is_set():
            server.handle_request()

    GATEWAY.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())

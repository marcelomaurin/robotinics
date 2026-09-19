#!/usr/bin/env python3
import json
import logging
import os
import queue
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
DEFAULT_RETRIES = int(os.getenv("ROBOTINICS_COMMAND_RETRIES", "1"))
HISTORY_SIZE = int(os.getenv("ROBOTINICS_HISTORY_SIZE", "200"))
EVENT_SIZE = int(os.getenv("ROBOTINICS_EVENT_SIZE", "200"))
HEARTBEAT_INTERVAL = float(os.getenv("ROBOTINICS_HEARTBEAT_INTERVAL", "1.0"))
HEARTBEAT_TIMEOUT = float(os.getenv("ROBOTINICS_HEARTBEAT_TIMEOUT", "2.0"))

CONNECTION_DISCONNECTED = "DISCONNECTED"
CONNECTION_CONNECTING = "CONNECTING"
CONNECTION_CONNECTED = "CONNECTED"
CONNECTION_DEGRADED = "DEGRADED"

PRIORITY_EMERGENCY = 0
PRIORITY_HIGH = 10
PRIORITY_NORMAL = 50
PRIORITY_LOW = 90

MOTION_COMMANDS = {"FRENTE", "RE", "GESQ", "GDIR"}
RETRY_SAFE_COMMANDS = {
    "PING", "SAFETY", "IDENTIFY", "CAPABILITIES", "ULTRA", "ULTRA1",
    "ULTRA2", "GAS", "CORR", "GPS", "ACEL", "VER"
}

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


def _priority_for(command, internal=False):
    if command == "PARA":
        return PRIORITY_EMERGENCY
    if internal and command == "PING":
        return PRIORITY_LOW
    if command in {"SAFETY", "IDENTIFY", "CAPABILITIES"}:
        return PRIORITY_HIGH
    return PRIORITY_NORMAL


class RobotState:
    def __init__(self):
        self.lock = threading.RLock()
        self.data = {
            "connected": False,
            "connection": {
                "state": CONNECTION_DISCONNECTED,
                "since": time.time(),
                "last_change_reason": "startup",
            },
            "serial_port": PORT,
            "serial_baud": BAUD,
            "last_seen": None,
            "last_line": None,
            "active_request_id": None,
            "device": None,
            "capabilities": [],
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

    def set_connection(self, state, reason=None):
        with self.lock:
            current = self.data["connection"]["state"]
            if current != state:
                self.data["connection"] = {
                    "state": state,
                    "since": time.time(),
                    "last_change_reason": reason,
                }
            elif reason is not None:
                self.data["connection"]["last_change_reason"] = reason
            self.data["connected"] = state == CONNECTION_CONNECTED
            self._save()

    def update(self, **kwargs):
        with self.lock:
            self.data.update(kwargs)
            self._save()

    def parse_line(self, line, active_command=None):
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
                    enabled = value.upper() == "ON"
                    mapping = {
                        "LASER": "laser",
                        "LEDAZUL": "led_blue",
                        "LEDVERDE": "led_green",
                        "LEDVERMELHO": "led_red",
                        "OLHOS": "eyes",
                        "LIGHTAUTO": "light_auto",
                    }
                    if name in mapping:
                        self.data["head"][mapping[name]] = enabled
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
                if capability not in self.data["capabilities"]:
                    self.data["capabilities"].append(capability)
            elif line.startswith("SAFETY:STOP:"):
                reason = line.split(":", 2)[2]
                self.data["motion"]["stopped"] = True
                self.data["motion"]["safety_stop_reason"] = reason
                self._fault("safety_stop", line)
            elif line.startswith("SAFETY:MOTION:"):
                self.data["motion"]["stopped"] = line.endswith(":STOPPED")
            elif line.startswith("SAFETY:LAST_STOP:"):
                self.data["motion"]["safety_stop_reason"] = line.split(":", 2)[2]
            elif active_command in {"ULTRA", "ULTRA1", "ULTRA2"} and line.startswith("Cent:"):
                try:
                    value = float(line.split(":", 1)[1].split(",", 1)[0].strip())
                    key = {"ULTRA": "ultra_cm", "ULTRA1": "ultra1_cm", "ULTRA2": "ultra2_cm"}[active_command]
                    self.data["sensors"][key] = value
                except (ValueError, IndexError):
                    pass
            elif active_command == "CORR" and line.startswith("Corrente:"):
                try:
                    self.data["sensors"]["current"] = float(line.split(":", 1)[1].strip())
                except ValueError:
                    pass
            elif active_command == "GAS":
                self.data["sensors"]["gas"] = line
            elif "Colisao eminente" in line:
                self._fault("collision_warning", line)
            elif line.lower().startswith("erro") or "ERR:" in line:
                self._fault("device_error", line)

            self._save()

    def note_command(self, command):
        with self.lock:
            if command == "PARA":
                self.data["motion"]["stopped"] = True
            elif command in MOTION_COMMANDS:
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
    def __init__(self, command, timeout, internal=False, retries=0, priority=None):
        self.id = str(uuid.uuid4())
        self.command = command
        self.timeout = float(timeout)
        self.internal = internal
        self.retries = max(0, int(retries))
        self.priority = _priority_for(command, internal) if priority is None else int(priority)
        self.created_at = time.time()
        self.started_at = None
        self.finished_at = None
        self.lines = []
        self.ok = False
        self.error = None
        self.attempts = 0
        self.cancelled = False
        self.cancel_reason = None
        self.done = threading.Event()

    def result(self):
        return {
            "request_id": self.id,
            "command": self.command,
            "ok": self.ok,
            "cancelled": self.cancelled,
            "cancel_reason": self.cancel_reason,
            "error": self.error,
            "priority": self.priority,
            "attempts": self.attempts,
            "retries": self.retries,
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
        self.command_queue = queue.PriorityQueue(maxsize=100)
        self.history = deque(maxlen=HISTORY_SIZE)
        self.events = deque(maxlen=EVENT_SIZE)
        self.serial_lock = threading.Lock()
        self.serial_obj = None
        self.active = None
        self.active_lock = threading.RLock()
        self.requests = {}
        self.requests_lock = threading.RLock()
        self.sequence = 0
        self.sequence_lock = threading.Lock()
        self.reader_thread = None
        self.worker_thread = None
        self.heartbeat_thread = None
        self.metrics_lock = threading.RLock()
        self.metrics = {
            "submitted": 0,
            "completed": 0,
            "failed": 0,
            "cancelled": 0,
            "retried": 0,
            "serial_reconnects": 0,
            "events": 0,
        }

    def _metric(self, name, delta=1):
        with self.metrics_lock:
            self.metrics[name] = self.metrics.get(name, 0) + delta

    def _event(self, event_type, **payload):
        item = {"timestamp": time.time(), "type": event_type, **payload}
        self.events.append(item)
        self._metric("events")
        return item

    def _next_sequence(self):
        with self.sequence_lock:
            self.sequence += 1
            return self.sequence

    def start(self):
        self.reader_thread = threading.Thread(target=self._serial_loop, name="serial-reader", daemon=True)
        self.worker_thread = threading.Thread(target=self._command_loop, name="command-worker", daemon=True)
        self.heartbeat_thread = threading.Thread(target=self._heartbeat_loop, name="safety-heartbeat", daemon=True)
        self.reader_thread.start()
        self.worker_thread.start()
        self.heartbeat_thread.start()

    def stop(self):
        RUN.clear()
        self.state.set_connection(CONNECTION_DISCONNECTED, "gateway_stop")
        with self.serial_lock:
            if self.serial_obj:
                try:
                    self.serial_obj.close()
                except Exception:
                    pass
                self.serial_obj = None

    def submit(self, command, timeout=None, internal=False, retries=None, priority=None):
        command = validate_command(command)
        if retries is None:
            retries = DEFAULT_RETRIES if command in RETRY_SAFE_COMMANDS else 0
        req = Request(
            command,
            float(timeout or DEFAULT_TIMEOUT),
            internal=internal,
            retries=retries,
            priority=priority,
        )
        with self.requests_lock:
            self.requests[req.id] = req
        try:
            self.command_queue.put((req.priority, self._next_sequence(), req), timeout=1)
        except queue.Full:
            with self.requests_lock:
                self.requests.pop(req.id, None)
            raise RuntimeError("command queue full")
        self._metric("submitted")
        self._event("request_queued", request_id=req.id, command=command, priority=req.priority)
        return req

    def cancel(self, request_id, reason="cancelled_by_client"):
        with self.requests_lock:
            req = self.requests.get(request_id)
        if req is None:
            return False, "request not found"
        if req.done.is_set():
            return False, "request already finished"

        req.cancelled = True
        req.cancel_reason = reason
        req.error = reason
        req.finished_at = time.time()
        req.done.set()
        self._metric("cancelled")
        self._event("request_cancelled", request_id=req.id, command=req.command, reason=reason)

        with self.active_lock:
            is_active = self.active is req

        if is_active and req.command in MOTION_COMMANDS:
            try:
                self.submit("PARA", timeout=2.0, internal=True, retries=0, priority=PRIORITY_EMERGENCY)
                self._event("safety_stop_queued", source_request_id=req.id)
            except Exception as exc:
                self._event("safety_stop_queue_failed", source_request_id=req.id, error=str(exc))
        return True, None

    def get_request(self, request_id):
        with self.requests_lock:
            req = self.requests.get(request_id)
        return req.result() if req else None

    def _open_serial(self):
        with self.serial_lock:
            if self.serial_obj and self.serial_obj.is_open:
                return self.serial_obj
            self.state.set_connection(CONNECTION_CONNECTING, "opening_serial")
            try:
                self.serial_obj = serial.Serial(PORT, BAUD, timeout=0.25, write_timeout=1)
                self.serial_obj.reset_input_buffer()
                self.state.set_connection(CONNECTION_CONNECTED, "serial_open")
                self.state.update(last_error=None)
                self._metric("serial_reconnects")
                self._event("connection", state=CONNECTION_CONNECTED, port=PORT, baud=BAUD)
                LOG.info("serial connected: %s @ %d", PORT, BAUD)
                return self.serial_obj
            except Exception as exc:
                self.state.set_connection(CONNECTION_DISCONNECTED, str(exc))
                raise

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
                with self.active_lock:
                    req = self.active
                    active_command = req.command if req else None

                self.state.parse_line(line, active_command=active_command)

                if line.startswith("SAFETY:STOP:"):
                    self._event("safety_stop", reason=line.split(":", 2)[2])
                elif line.startswith("RBT:") or line.startswith("MCAB:"):
                    self._event("device_line", line=line)

                with self.active_lock:
                    req = self.active
                    if req and not req.cancelled:
                        if line == "$>":
                            req.ok = True
                            req.finished_at = time.time()
                            req.done.set()
                        else:
                            req.lines.append(line)
            except serial.SerialException as exc:
                LOG.warning("serial unavailable: %s", exc)
                self.state.update(last_error=str(exc))
                self.state.set_connection(CONNECTION_DISCONNECTED, str(exc))
                self._event("connection", state=CONNECTION_DISCONNECTED, error=str(exc))
                with self.serial_lock:
                    if self.serial_obj:
                        try:
                            self.serial_obj.close()
                        except Exception:
                            pass
                        self.serial_obj = None
                time.sleep(1)
            except Exception as exc:
                LOG.exception("serial reader error: %s", exc)
                self.state.update(last_error=str(exc))
                self.state.set_connection(CONNECTION_DEGRADED, str(exc))
                self._event("connection", state=CONNECTION_DEGRADED, error=str(exc))
                time.sleep(0.5)

    def _heartbeat_loop(self):
        while RUN.is_set():
            time.sleep(max(0.2, HEARTBEAT_INTERVAL))
            if not RUN.is_set():
                break

            snapshot = self.state.snapshot()
            moving = snapshot.get("motion", {}).get("stopped") is False
            connected = snapshot.get("connection", {}).get("state") == CONNECTION_CONNECTED

            if not moving or not connected:
                continue

            with self.active_lock:
                busy = self.active is not None
            if busy or not self.command_queue.empty():
                continue

            try:
                self.submit("PING", HEARTBEAT_TIMEOUT, internal=True, retries=0, priority=PRIORITY_LOW)
            except Exception as exc:
                LOG.warning("heartbeat submit failed: %s", exc)

    def _execute_attempt(self, req):
        req.attempts += 1
        req.lines = []
        req.done.clear()

        ser = self._open_serial()
        payload = (req.command + "\n").encode("utf-8")
        with self.serial_lock:
            ser.write(payload)
            ser.flush()

        self.state.note_command(req.command)

        if not req.done.wait(req.timeout):
            if req.cancelled:
                return False
            req.error = "timeout waiting for device prompt"
            return False
        return req.ok and not req.cancelled

    def _command_loop(self):
        while RUN.is_set():
            try:
                _priority, _sequence, req = self.command_queue.get(timeout=0.5)
            except queue.Empty:
                continue

            try:
                if req.cancelled:
                    continue

                req.started_at = time.time()
                with self.active_lock:
                    self.active = req
                    self.state.update(active_request_id=req.id)

                max_attempts = 1 + req.retries
                while req.attempts < max_attempts and not req.cancelled:
                    if self._execute_attempt(req):
                        break
                    if req.attempts < max_attempts:
                        self._metric("retried")
                        self._event(
                            "request_retry",
                            request_id=req.id,
                            command=req.command,
                            next_attempt=req.attempts + 1,
                        )
                        time.sleep(0.05)

                if not req.cancelled and not req.ok:
                    req.finished_at = time.time()
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

                if req.finished_at is None and req.done.is_set():
                    req.finished_at = time.time()

                result = req.result()
                if req.cancelled:
                    pass
                elif req.ok:
                    self._metric("completed")
                else:
                    self._metric("failed")

                if not req.internal:
                    self.history.append(result)
                    self._append_history(result)
                self._event(
                    "request_finished",
                    request_id=req.id,
                    command=req.command,
                    ok=req.ok,
                    cancelled=req.cancelled,
                    attempts=req.attempts,
                )
                self.command_queue.task_done()

    def _append_history(self, item):
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        with HISTORY_FILE.open("a", encoding="utf-8") as fp:
            fp.write(json.dumps(item, ensure_ascii=False) + "\n")

    def status(self):
        with self.metrics_lock:
            metrics = dict(self.metrics)
        return {
            "gateway": {
                "api_version": 2,
                "serial_port": PORT,
                "serial_baud": BAUD,
                "listen": f"http://{LISTEN_HOST}:{LISTEN_PORT}",
                "queue_size": self.command_queue.qsize(),
                "heartbeat_interval": HEARTBEAT_INTERVAL,
                "default_retries": DEFAULT_RETRIES,
            },
            "metrics": metrics,
            "state": self.state.snapshot(),
        }


GATEWAY = Gateway()


class Handler(BaseHTTPRequestHandler):
    server_version = "RobotinicsGateway/2.0"

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

    def _catalog(self):
        return {
            "ok": True,
            "exact": sorted(EXACT_COMMANDS),
            "angle_prefixes": ANGLE_PREFIXES,
            "mcab_exact": sorted(MCAB_EXACT),
            "mcab_bool_prefixes": MCAB_BOOL_PREFIXES,
            "priorities": {
                "emergency": PRIORITY_EMERGENCY,
                "high": PRIORITY_HIGH,
                "normal": PRIORITY_NORMAL,
                "low": PRIORITY_LOW,
            },
        }

    def do_GET(self):
        if self.path in {"/v1/ping", "/v2/ping"}:
            self._json(200, {"ok": True, "pong": time.time(), "api_version": 2})
        elif self.path in {"/v1/state", "/v2/state"}:
            self._json(200, {"ok": True, **GATEWAY.status()})
        elif self.path in {"/v1/catalog", "/v2/catalog"}:
            self._json(200, self._catalog())
        elif self.path.startswith("/v1/history") or self.path.startswith("/v2/history"):
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
        elif self.path.startswith("/v2/events"):
            limit = 50
            if "?" in self.path:
                try:
                    query = self.path.split("?", 1)[1]
                    for item in query.split("&"):
                        if item.startswith("limit="):
                            limit = int(item.split("=", 1)[1])
                except ValueError:
                    limit = 50
            limit = max(1, min(limit, EVENT_SIZE))
            self._json(200, {"ok": True, "events": list(GATEWAY.events)[-limit:]})
        elif self.path.startswith("/v2/request/"):
            request_id = self.path.rsplit("/", 1)[1]
            result = GATEWAY.get_request(request_id)
            if result is None:
                self._json(404, {"ok": False, "error": "request not found"})
            else:
                self._json(200, {"ok": True, "request": result})
        else:
            self._json(404, {"ok": False, "error": "not found"})

    def do_POST(self):
        try:
            if self.path in {"/v1/command", "/v2/command"}:
                payload = self._read_json()
                req = GATEWAY.submit(
                    payload.get("command", ""),
                    payload.get("timeout"),
                    retries=payload.get("retries"),
                    priority=payload.get("priority"),
                )
                if payload.get("async", False) and self.path == "/v2/command":
                    self._json(202, {
                        "ok": True,
                        "request_id": req.id,
                        "priority": req.priority,
                    })
                    return

                if not req.done.wait(req.timeout * (1 + req.retries) + 1.0):
                    self._json(504, {
                        "ok": False,
                        "request_id": req.id,
                        "error": "gateway wait timeout",
                    })
                else:
                    result = req.result()
                    status = 200 if result["ok"] else (409 if result["cancelled"] else 504)
                    self._json(status, result)
                return

            if self.path.startswith("/v2/cancel/"):
                request_id = self.path.rsplit("/", 1)[1]
                payload = {}
                try:
                    payload = self._read_json()
                except ValueError:
                    pass
                ok, error = GATEWAY.cancel(request_id, payload.get("reason", "cancelled_by_client"))
                self._json(200 if ok else 409, {
                    "ok": ok,
                    "request_id": request_id,
                    "error": error,
                })
                return

            self._json(404, {"ok": False, "error": "not found"})
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

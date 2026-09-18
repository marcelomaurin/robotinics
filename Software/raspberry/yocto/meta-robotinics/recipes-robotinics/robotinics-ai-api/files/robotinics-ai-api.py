#!/usr/bin/env python3
import json
import logging
import os
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LOG = logging.getLogger("robotinics-ai-api")
HOST = os.getenv("ROBOTINICS_AI_HOST", "127.0.0.1")
PORT = int(os.getenv("ROBOTINICS_AI_PORT", "8766"))
BIN = os.getenv("ROBOTINICS_AI_BIN", "/opt/robotinics/ai/robotinics-ai")
TIMEOUT = int(os.getenv("ROBOTINICS_AI_REQUEST_TIMEOUT", "150"))
LOCK = threading.Lock()


class Handler(BaseHTTPRequestHandler):
    server_version = "RobotinicsAI/1.0"

    def log_message(self, fmt, *args):
        LOG.info("api: " + fmt, *args)

    def send_json(self, status, payload):
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def read_json(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length <= 0 or length > 32768:
            raise ValueError("invalid content length")
        return json.loads(self.rfile.read(length).decode("utf-8"))

    def do_GET(self):
        if self.path == "/v1/ping":
            self.send_json(200, {"ok": True, "pong": time.time()})
        else:
            self.send_json(404, {"ok": False, "error": "not found"})

    def do_POST(self):
        if self.path != "/v1/ask":
            self.send_json(404, {"ok": False, "error": "not found"})
            return

        try:
            payload = self.read_json()
            question = str(payload.get("question", "")).strip()
            if not question:
                raise ValueError("question is required")
            if len(question) > 12000:
                raise ValueError("question too large")

            with LOCK:
                proc = subprocess.run(
                    [BIN, question],
                    capture_output=True,
                    text=True,
                    timeout=TIMEOUT,
                    env=os.environ.copy(),
                )

            self.send_json(
                200 if proc.returncode == 0 else 502,
                {
                    "ok": proc.returncode == 0,
                    "answer": proc.stdout.strip(),
                    "stderr": proc.stderr.strip(),
                    "exit_code": proc.returncode,
                },
            )
        except subprocess.TimeoutExpired:
            self.send_json(504, {"ok": False, "error": "AI timeout"})
        except (ValueError, TypeError, json.JSONDecodeError) as exc:
            self.send_json(400, {"ok": False, "error": str(exc)})
        except Exception as exc:
            LOG.exception("request failed: %s", exc)
            self.send_json(500, {"ok": False, "error": str(exc)})


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    with ThreadingHTTPServer((HOST, PORT), Handler) as server:
        LOG.info("AI API listening on http://%s:%d", HOST, PORT)
        server.serve_forever()


if __name__ == "__main__":
    main()

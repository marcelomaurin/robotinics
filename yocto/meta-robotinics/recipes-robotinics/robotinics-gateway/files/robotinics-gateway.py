#!/usr/bin/env python3
import json
import logging
import os
import signal
import sys
import time
from pathlib import Path

import serial

LOG = logging.getLogger("robotinics-gateway")
RUN = True

PORT = os.getenv("ROBOTINICS_SERIAL_PORT", "/dev/ttyACM0")
BAUD = int(os.getenv("ROBOTINICS_SERIAL_BAUD", "115200"))
STATE = Path(os.getenv("ROBOTINICS_STATE_PATH", "/var/lib/robotinics"))
STATE_FILE = STATE / "gateway-state.json"


def stop_handler(signum, frame):
    global RUN
    RUN = False


def save_state(**kwargs):
    STATE.mkdir(parents=True, exist_ok=True)
    data = {"port": PORT, "baud": BAUD, "timestamp": time.time(), **kwargs}
    tmp = STATE_FILE.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2))
    tmp.replace(STATE_FILE)


def run_once():
    LOG.info("opening serial %s at %d", PORT, BAUD)
    with serial.Serial(PORT, BAUD, timeout=1, write_timeout=1) as ser:
        save_state(connected=True)
        ser.reset_input_buffer()
        while RUN:
            raw = ser.readline()
            if not raw:
                continue
            line = raw.decode("utf-8", errors="replace").strip()
            if not line:
                continue
            LOG.info("mega: %s", line)
            save_state(connected=True, last_line=line)


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    signal.signal(signal.SIGTERM, stop_handler)
    signal.signal(signal.SIGINT, stop_handler)
    while RUN:
        try:
            run_once()
        except serial.SerialException as exc:
            LOG.warning("serial unavailable: %s", exc)
            save_state(connected=False, error=str(exc))
            time.sleep(2)
        except Exception as exc:
            LOG.exception("gateway error: %s", exc)
            save_state(connected=False, error=str(exc))
            time.sleep(2)
    save_state(connected=False, stopped=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())

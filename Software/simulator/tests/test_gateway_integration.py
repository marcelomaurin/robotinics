import importlib.util
import os
import pty
import select
import tempfile
import threading
import time
import unittest
from pathlib import Path

SIM_DIR = Path(__file__).resolve().parents[1]
SOFTWARE_DIR = Path(__file__).resolve().parents[2]
SIM_PATH = SIM_DIR / "robotinics_simulator.py"
GW_PATH = SOFTWARE_DIR / "raspberry" / "Gateway" / "robotinics_gateway.py"

sim_spec = importlib.util.spec_from_file_location("robotinics_simulator", SIM_PATH)
simmod = importlib.util.module_from_spec(sim_spec)
sim_spec.loader.exec_module(simmod)

os.environ["ROBOTINICS_STATE_PATH"] = tempfile.mkdtemp(prefix="robotinics-gw-integration-")
gw_spec = importlib.util.spec_from_file_location("robotinics_gateway_integration", GW_PATH)
gw = importlib.util.module_from_spec(gw_spec)
gw_spec.loader.exec_module(gw)


class SerialHarness:
    def __init__(self):
        self.master_fd, self.slave_fd = pty.openpty()
        self.slave_name = os.ttyname(self.slave_fd)
        self.sim = simmod.RobotinicsSimulator(watchdog_s=2, motion_timeout_s=5)
        self.running = True
        self.thread = threading.Thread(target=self._loop, daemon=True)

    def start(self):
        self.thread.start()

    def stop(self):
        self.running = False
        self.thread.join(timeout=1)
        os.close(self.master_fd)
        os.close(self.slave_fd)

    def _loop(self):
        buffer = b""
        while self.running:
            for event in self.sim.tick():
                os.write(self.master_fd, (event + "\n").encode())

            ready, _, _ = select.select([self.master_fd], [], [], 0.02)
            if not ready:
                continue
            try:
                chunk = os.read(self.master_fd, 1024)
            except OSError:
                return
            buffer += chunk
            while b"\n" in buffer:
                raw, buffer = buffer.split(b"\n", 1)
                command = raw.decode(errors="replace").strip("\r")
                for line in self.sim.command(command):
                    os.write(self.master_fd, (line + "\n").encode())


class GatewaySimulatorIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.harness = SerialHarness()
        self.harness.start()

        gw.RUN.set()
        gw.PORT = self.harness.slave_name
        gw.STATE_DIR = Path(tempfile.mkdtemp(prefix="robotinics-gw-state-"))
        gw.STATE_FILE = gw.STATE_DIR / "gateway-state.json"
        gw.HISTORY_FILE = gw.STATE_DIR / "gateway-history.jsonl"
        self.gateway = gw.Gateway()
        self.gateway.start()

        deadline = time.time() + 2
        while time.time() < deadline:
            if self.gateway.state.snapshot()["connected"]:
                break
            time.sleep(0.02)

    def tearDown(self):
        self.gateway.stop()
        self.harness.stop()
        gw.RUN.set()

    def execute(self, command, timeout=2):
        req = self.gateway.submit(command, timeout)
        self.assertTrue(req.done.wait(timeout + 0.5))
        self.assertTrue(req.ok, req.result())
        return req.result()

    def test_identify_and_capabilities(self):
        self.execute("IDENTIFY")
        self.execute("CAPABILITIES")
        snap = self.gateway.state.snapshot()
        self.assertEqual(snap["device"]["board"], "MEGA2560")
        self.assertIn("MOTION", snap["capabilities"])
        self.assertIn("SAFETY_WATCHDOG", snap["capabilities"])

    def test_motion_safety_and_mcabeça(self):
        self.execute("FRENTE")
        self.assertFalse(self.gateway.state.snapshot()["motion"]["stopped"])

        result = self.execute("SAFETY")
        self.assertIn("SAFETY:MOTION:ACTIVE", result["lines"])

        head = self.execute("MCAB:DIST")
        self.assertTrue(any(line.startswith("MCAB:DIST:") for line in head["lines"]))

        self.execute("PARA")
        self.assertTrue(self.gateway.state.snapshot()["motion"]["stopped"])


if __name__ == "__main__":
    unittest.main()

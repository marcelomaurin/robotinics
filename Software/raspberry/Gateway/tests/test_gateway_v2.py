import importlib.util
import os
import tempfile
import time
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "robotinics_gateway.py"
os.environ.setdefault("ROBOTINICS_STATE_PATH", tempfile.mkdtemp(prefix="robotinics-gw2-test-"))

spec = importlib.util.spec_from_file_location("robotinics_gateway_v2", MODULE_PATH)
gateway = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gateway)


class GatewayV2ModelTests(unittest.TestCase):
    def setUp(self):
        gateway.STATE_DIR = Path(tempfile.mkdtemp(prefix="robotinics-state-v2-"))
        gateway.STATE_FILE = gateway.STATE_DIR / "gateway-state.json"
        gateway.HISTORY_FILE = gateway.STATE_DIR / "gateway-history.jsonl"

    def test_priority_order(self):
        self.assertLess(
            gateway._priority_for("PARA"),
            gateway._priority_for("FRENTE"),
        )
        self.assertGreater(
            gateway._priority_for("PING", internal=True),
            gateway._priority_for("FRENTE"),
        )

    def test_retry_only_safe_by_default(self):
        g = gateway.Gateway()
        diag = g.submit("IDENTIFY")
        motion = g.submit("FRENTE")
        self.assertEqual(diag.retries, gateway.DEFAULT_RETRIES)
        self.assertEqual(motion.retries, 0)

    def test_cancel_queued_request(self):
        g = gateway.Gateway()
        req = g.submit("IDENTIFY")
        ok, error = g.cancel(req.id, "test_cancel")
        self.assertTrue(ok)
        self.assertIsNone(error)
        self.assertTrue(req.cancelled)
        self.assertTrue(req.done.is_set())
        self.assertEqual(req.cancel_reason, "test_cancel")

    def test_connection_state_model(self):
        state = gateway.RobotState()
        state.set_connection(gateway.CONNECTION_CONNECTING, "test")
        self.assertEqual(
            state.snapshot()["connection"]["state"],
            gateway.CONNECTION_CONNECTING,
        )
        state.set_connection(gateway.CONNECTION_CONNECTED, "test")
        snap = state.snapshot()
        self.assertTrue(snap["connected"])
        self.assertEqual(
            snap["connection"]["state"],
            gateway.CONNECTION_CONNECTED,
        )

    def test_structured_legacy_telemetry(self):
        state = gateway.RobotState()
        state.parse_line("Cent: 42.50, Pol. : 16.73", active_command="ULTRA1")
        state.parse_line("Corrente:1.25", active_command="CORR")
        snap = state.snapshot()
        self.assertEqual(snap["sensors"]["ultra1_cm"], 42.5)
        self.assertEqual(snap["sensors"]["current"], 1.25)

    def test_request_result_contains_v2_fields(self):
        req = gateway.Request("PING", 1, retries=2, priority=7)
        result = req.result()
        self.assertEqual(result["priority"], 7)
        self.assertEqual(result["retries"], 2)
        self.assertIn("attempts", result)
        self.assertIn("cancelled", result)


class DiagnosticsTests(unittest.TestCase):
    def setUp(self):
        gateway.STATE_DIR = Path(tempfile.mkdtemp(prefix="robotinics-diagnostics-"))
        gateway.STATE_FILE = gateway.STATE_DIR / "gateway-state.json"
        gateway.HISTORY_FILE = gateway.STATE_DIR / "gateway-history.jsonl"
        self.g = gateway.Gateway()

    def test_health_lines_update_state(self):
        self.g.state.parse_line("RBT:HEALTH:BODY:OK")
        self.g.state.parse_line("RBT:HEALTH:SAFETY:IDLE")
        self.g.state.parse_line("MCAB:HEALTH:HEAD:OK")
        self.g.state.parse_line("RBT:TELEM:ULTRA_FRONT_CM:35.5")
        snap = self.g.state.snapshot()
        self.assertEqual(snap["health"]["body"], "OK")
        self.assertEqual(snap["health"]["head"], "OK")
        self.assertEqual(snap["health"]["safety"], "IDLE")
        self.assertEqual(snap["telemetry"]["ultra_front_cm"], 35.5)

    def test_diagnostics_ok(self):
        self.g.state.set_connection(gateway.CONNECTION_CONNECTED, "test")
        self.g.state.parse_line("RBT:HEALTH:BODY:OK")
        self.g.state.parse_line("MCAB:HEALTH:HEAD:OK")
        result = self.g.diagnose()
        self.assertEqual(result["overall"], "OK")
        self.assertEqual(result["issues"], [])

    def test_diagnostics_connection_error(self):
        result = self.g.diagnose()
        self.assertEqual(result["overall"], "ERROR")
        self.assertTrue(any(i["code"] == "connection" for i in result["issues"]))

    def test_diagnostics_obstacle_warning(self):
        self.g.state.set_connection(gateway.CONNECTION_CONNECTED, "test")
        self.g.state.parse_line("RBT:HEALTH:BODY:OK")
        self.g.state.parse_line("MCAB:HEALTH:HEAD:OK")
        self.g.state.parse_line("Cent: 10.0, Pol. : 3.94", active_command="ULTRA1")
        result = self.g.diagnose()
        self.assertEqual(result["overall"], "WARN")
        self.assertTrue(any(i["code"] == "front_obstacle" for i in result["issues"]))


if __name__ == "__main__":
    unittest.main()

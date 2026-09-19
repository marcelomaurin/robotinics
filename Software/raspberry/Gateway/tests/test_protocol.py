import importlib.util
import os
import tempfile
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "robotinics_gateway.py"

os.environ.setdefault("ROBOTINICS_STATE_PATH", tempfile.mkdtemp(prefix="robotinics-test-"))

spec = importlib.util.spec_from_file_location("robotinics_gateway", MODULE_PATH)
gateway = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gateway)


class ValidateCommandTests(unittest.TestCase):
    def test_exact_commands(self):
        for command in (
            "PARA", "FRENTE", "RE", "GESQ", "GDIR",
            "PING", "SAFETY", "IDENTIFY", "CAPABILITIES",
        ):
            self.assertEqual(gateway.validate_command(command), command)

    def test_angle_command(self):
        self.assertEqual(
            gateway.validate_command("GCABECADIR=90"),
            "GCABECADIR=90",
        )

    def test_angle_out_of_range(self):
        with self.assertRaises(ValueError):
            gateway.validate_command("GCABECADIR=181")

    def test_mcabeça_point(self):
        self.assertEqual(
            gateway.validate_command("MCAB:POINT:90,45"),
            "MCAB:POINT:90,45",
        )

    def test_unknown_command_rejected(self):
        with self.assertRaises(ValueError):
            gateway.validate_command("EXECUTE_ANYTHING")


class RobotStateProtocolTests(unittest.TestCase):
    def setUp(self):
        gateway.STATE_DIR = Path(tempfile.mkdtemp(prefix="robotinics-state-"))
        gateway.STATE_FILE = gateway.STATE_DIR / "gateway-state.json"
        gateway.HISTORY_FILE = gateway.STATE_DIR / "gateway-history.jsonl"
        self.state = gateway.RobotState()

    def test_identify(self):
        self.state.parse_line("RBT:IDENTIFY:BODY:MEGA2560:1.3")
        snap = self.state.snapshot()
        self.assertEqual(snap["device"]["role"], "BODY")
        self.assertEqual(snap["device"]["board"], "MEGA2560")
        self.assertEqual(snap["device"]["version"], "1.3")

    def test_capabilities_are_unique(self):
        self.state.parse_line("RBT:CAP:MOTION")
        self.state.parse_line("RBT:CAP:MOTION")
        snap = self.state.snapshot()
        self.assertEqual(snap["capabilities"], ["MOTION"])

    def test_safety_stop_updates_motion(self):
        self.state.parse_line("SAFETY:STOP:control_watchdog")
        snap = self.state.snapshot()
        self.assertTrue(snap["motion"]["stopped"])
        self.assertEqual(
            snap["motion"]["safety_stop_reason"],
            "control_watchdog",
        )
        self.assertEqual(snap["faults"][-1]["code"], "safety_stop")


if __name__ == "__main__":
    unittest.main()

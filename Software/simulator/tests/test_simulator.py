import importlib.util
import time
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "robotinics_simulator.py"
spec = importlib.util.spec_from_file_location("robotinics_simulator", MODULE_PATH)
simmod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(simmod)


class SimulatorProtocolTests(unittest.TestCase):
    def setUp(self):
        self.sim = simmod.RobotinicsSimulator(
            collision_margin_cm=20,
            watchdog_s=0.05,
            motion_timeout_s=0.10,
        )

    def test_identify_and_capabilities(self):
        self.assertEqual(
            self.sim.command("IDENTIFY")[0],
            "RBT:IDENTIFY:BODY:MEGA2560:1.3",
        )
        caps = self.sim.command("CAPABILITIES")
        self.assertIn("RBT:CAP:MOTION", caps)
        self.assertEqual(caps[-1], "$>")

    def test_motion_and_stop(self):
        self.sim.command("FRENTE")
        self.assertEqual(self.sim.body.motion, "FRENTE")
        self.sim.command("PARA")
        self.assertEqual(self.sim.body.motion, "STOPPED")

    def test_front_collision(self):
        self.sim.set_sensor("ultra1", 10)
        self.sim.command("FRENTE")
        events = self.sim.tick()
        self.assertIn("SAFETY:STOP:front_obstacle", events)
        self.assertEqual(self.sim.body.motion, "STOPPED")

    def test_control_watchdog(self):
        self.sim.command("FRENTE")
        time.sleep(0.06)
        events = self.sim.tick()
        self.assertIn("SAFETY:STOP:control_watchdog", events)

    def test_motion_timeout(self):
        self.sim = simmod.RobotinicsSimulator(watchdog_s=1, motion_timeout_s=0.05)
        self.sim.command("FRENTE")
        # PING keeps control alive but must not renew the motion lease.
        time.sleep(0.03)
        self.sim.command("PING")
        time.sleep(0.03)
        events = self.sim.tick()
        self.assertIn("SAFETY:STOP:motion_timeout", events)

    def test_health(self):
        response = self.sim.command("HEALTH")
        self.assertIn("RBT:HEALTH:BODY:OK", response)
        self.assertIn("MCAB:HEALTH:HEAD:OK", response)
        self.assertTrue(any(line.startswith("RBT:TELEM:ULTRA_FRONT_CM:") for line in response))

    def test_head_bridge(self):
        response = self.sim.command("MCAB:POINT:100,50")
        self.assertIn("MCAB:POS:100,50", response)
        self.assertEqual(self.sim.head.x, 100)
        self.assertEqual(self.sim.head.y, 50)


if __name__ == "__main__":
    unittest.main()

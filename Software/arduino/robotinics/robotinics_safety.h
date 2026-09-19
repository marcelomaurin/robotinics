#ifndef ROBOTINICS_SAFETY_H
#define ROBOTINICS_SAFETY_H

#include <Arduino.h>

enum RobotSafetyStopReason {
  SAFETY_STOP_NONE = 0,
  SAFETY_STOP_COMMAND,
  SAFETY_STOP_FRONT_OBSTACLE,
  SAFETY_STOP_REAR_OBSTACLE,
  SAFETY_STOP_MOTION_TIMEOUT,
  SAFETY_STOP_CONTROL_WATCHDOG
};

void SafetyRegisterControlActivity();
void SafetyArmMotion();
void SafetyDisarmMotion();
void SafetyStop(RobotSafetyStopReason reason, bool announce);
bool SafetyMotionActive();
const char *SafetyLastStopReason();
void SafetyCheckTimeouts();
void fMargem(bool flgView);

#endif

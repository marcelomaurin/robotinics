// Seguranca ---------------------------------------------------------------

static unsigned long safetyLastControlActivityMs = 0;
static unsigned long safetyMotionStartedMs = 0;
static bool safetyMotionActive = false;
static RobotSafetyStopReason safetyLastStopReason = SAFETY_STOP_NONE;

static const char *SafetyReasonText(RobotSafetyStopReason reason)
{
  switch (reason) {
    case SAFETY_STOP_COMMAND:          return "command";
    case SAFETY_STOP_FRONT_OBSTACLE:   return "front_obstacle";
    case SAFETY_STOP_REAR_OBSTACLE:    return "rear_obstacle";
    case SAFETY_STOP_MOTION_TIMEOUT:   return "motion_timeout";
    case SAFETY_STOP_CONTROL_WATCHDOG: return "control_watchdog";
    default:                           return "none";
  }
}

void SafetyRegisterControlActivity()
{
  safetyLastControlActivityMs = millis();
}

void SafetyArmMotion()
{
  const unsigned long now = millis();
  safetyMotionStartedMs = now;
  safetyLastControlActivityMs = now;
  safetyMotionActive = true;
  safetyLastStopReason = SAFETY_STOP_NONE;
}

void SafetyDisarmMotion()
{
  safetyMotionActive = false;
}

void SafetyStop(RobotSafetyStopReason reason, bool announce)
{
  // Para() desabilita primeiro ENA/ENB. A causa e registrada depois.
  Para();
  safetyLastStopReason = reason;

  if (announce) {
    Print("SAFETY:STOP:");
    Println(String(SafetyReasonText(reason)));
  }
}

bool SafetyMotionActive()
{
  return safetyMotionActive;
}

const char *SafetyLastStopReason()
{
  return SafetyReasonText(safetyLastStopReason);
}

void SafetyCheckTimeouts()
{
  if (!ROBOTINICS_SAFETY_TIMEOUTS_ENABLED || !safetyMotionActive)
    return;

  const unsigned long now = millis();

  if ((unsigned long)(now - safetyMotionStartedMs) >= ROBOTINICS_MOTION_TIMEOUT_MS) {
    SafetyStop(SAFETY_STOP_MOTION_TIMEOUT, true);
    return;
  }

  if ((unsigned long)(now - safetyLastControlActivityMs) >= ROBOTINICS_CONTROL_WATCHDOG_MS) {
    SafetyStop(SAFETY_STOP_CONTROL_WATCHDOG, true);
  }
}

void fMargem(bool flgView)
{
  if (Is_RE() && cmRe < Margem) {
    if (flgView) {
      Print("Margem Seguranca RE ");
      Println(String(cmRe) + " cm");
    }
    SafetyStop(SAFETY_STOP_REAR_OBSTACLE, true);
  }

  if (Is_FRENTE() && cmCorpo < Margem) {
    if (flgView) {
      Print("Margem Seguranca da Frente ");
      Println(String(cmCorpo) + " cm");
    }
    SafetyStop(SAFETY_STOP_FRONT_OBSTACLE, true);
  }
}

void Leituras()
{
  Le_Ultrasom(0);
  Le_Ultrasom1(0);

  // Recepcao vem antes das verificacoes de timeout para que um comando
  // valido recebido neste ciclo renove imediatamente a atividade.
  Le_Arduino();
  Le_Bluetooth();
  Le_Serial();

  Carrega_gas();
  Carrega_corr();
  Carrega_acel();
  Carrega_RC();

  // Carrega_Monitor permanece desabilitado como no firmware 1.3.
  fMargem(true);
  SafetyCheckTimeouts();
}

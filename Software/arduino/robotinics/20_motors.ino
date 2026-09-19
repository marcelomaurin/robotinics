// Motores de tracao -------------------------------------------------------

void StartMotor()
{
  pinMode(PINO_ENA, OUTPUT);
  pinMode(PINO_ENB, OUTPUT);
  pinMode(PINO_IN1, OUTPUT);
  pinMode(PINO_IN2, OUTPUT);
  pinMode(PINO_IN3, OUTPUT);
  pinMode(PINO_IN4, OUTPUT);
  Para();
}

void Liga()
{
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, LOW);
  digitalWrite(PINO_ENA, HIGH);
  digitalWrite(PINO_ENB, HIGH);
}

void Para()
{
  // ENA/ENB sao desligados primeiro para priorizar a parada fisica.
  digitalWrite(PINO_ENA, LOW);
  digitalWrite(PINO_ENB, LOW);
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, LOW);
  SafetyDisarmMotion();
}

bool Is_FRENTE()
{
  const bool flgIN1 = digitalRead(PINO_IN1) == LOW;
  const bool flgIN2 = digitalRead(PINO_IN2) == HIGH;
  const bool flgIN3 = digitalRead(PINO_IN3) == LOW;
  const bool flgIN4 = digitalRead(PINO_IN4) == HIGH;
  const bool flgENA = digitalRead(PINO_ENA) == HIGH;
  const bool flgENB = digitalRead(PINO_ENB) == HIGH;
  return flgIN1 && flgIN2 && flgIN3 && flgIN4 && flgENA && flgENB;
}

bool Is_RE()
{
  const bool flgIN1 = digitalRead(PINO_IN1) == HIGH;
  const bool flgIN2 = digitalRead(PINO_IN2) == LOW;
  const bool flgIN3 = digitalRead(PINO_IN3) == HIGH;
  const bool flgIN4 = digitalRead(PINO_IN4) == LOW;
  const bool flgENA = digitalRead(PINO_ENA) == HIGH;
  const bool flgENB = digitalRead(PINO_ENB) == HIGH;
  return flgIN1 && flgIN2 && flgIN3 && flgIN4 && flgENA && flgENB;
}

void Frente()
{
  SafetyArmMotion();
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, HIGH);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, HIGH);
  digitalWrite(PINO_ENA, HIGH);
  digitalWrite(PINO_ENB, HIGH);
}

void Re()
{
  SafetyArmMotion();
  digitalWrite(PINO_IN1, HIGH);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, HIGH);
  digitalWrite(PINO_IN4, LOW);
  digitalWrite(PINO_ENA, HIGH);
  digitalWrite(PINO_ENB, HIGH);
}

void GiraDir(int Angulo)
{
  SafetyArmMotion();
  (void)Angulo; // parametro mantido por compatibilidade
  digitalWrite(PINO_IN1, HIGH);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, HIGH);
  digitalWrite(PINO_ENA, HIGH);
  digitalWrite(PINO_ENB, HIGH);
}

void GiraEsq(int Angulo)
{
  SafetyArmMotion();
  (void)Angulo; // parametro mantido por compatibilidade
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, HIGH);
  digitalWrite(PINO_IN3, HIGH);
  digitalWrite(PINO_IN4, LOW);
  digitalWrite(PINO_ENA, HIGH);
  digitalWrite(PINO_ENB, HIGH);
}

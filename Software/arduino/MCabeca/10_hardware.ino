// Hardware -----------------------------------------------------------------

void Start_Serial()
{
  Serial.begin(57600);
  Versao();
}

void Start_Servo()
{
  CabecaX.attach(PIN_CABECA_X);
  CabecaY.attach(PIN_CABECA_Y);
  currentX = CABECA_X_HOME;
  currentY = CABECA_Y_HOME;
  CabecaX.write(currentX);
  CabecaY.write(currentY);
}

void Start_Olhos()
{
  pinMode(PIN_OLHOS, OUTPUT);
  digitalWrite(PIN_OLHOS, LOW);
}

void Start_Cores()
{
  pinMode(PIN_LED_AZUL, OUTPUT);
  pinMode(PIN_LED_VERDE, OUTPUT);
  pinMode(PIN_LED_VERMELHO, OUTPUT);

  digitalWrite(PIN_LED_AZUL, LOW);
  digitalWrite(PIN_LED_VERDE, LOW);
  digitalWrite(PIN_LED_VERMELHO, LOW);
}

void Start_Laser()
{
  pinMode(PIN_LASER, OUTPUT);
  LaserOFF();
}

void LedCabecaAzul(bool flag)
{
  digitalWrite(PIN_LED_AZUL, flag ? HIGH : LOW);
}

void LedCabecaVerde(bool flag)
{
  digitalWrite(PIN_LED_VERDE, flag ? HIGH : LOW);
}

void LedCabecaVermelho(bool flag)
{
  digitalWrite(PIN_LED_VERMELHO, flag ? HIGH : LOW);
}

void LedOlhos(bool flag)
{
  digitalWrite(PIN_OLHOS, flag ? HIGH : LOW);
}

void Olhos(int Luz)
{
  digitalWrite(PIN_OLHOS, Luz);
}

void LaserON()
{
  digitalWrite(PIN_LASER, HIGH);
}

void LaserOFF()
{
  digitalWrite(PIN_LASER, LOW);
}

void Point(int y, int x)
{
  currentY = (uint8_t)constrain(y, 0, 180);
  currentX = (uint8_t)constrain(x, 0, 180);

  CabecaY.write(currentY);
  CabecaX.write(currentX);
}

void VariaLuz()
{
  if (!lightAuto) return;

  const unsigned long agora = millis();
  if (agora - ultimoPassoLuz < INTERVALO_LUZ_MS) return;

  ultimoPassoLuz = agora;
  contcor++;

  // No codigo anterior '(contcor & 16) == 1' nunca era verdadeiro.
  if ((contcor & 16) != 0)
  {
    LedCabecaAzul(false);
    LedCabecaVerde(false);
    LedCabecaVermelho(false);
    LedOlhos(true);
  }
  else
  {
    LedOlhos(false);
    LedCabecaAzul((contcor & 2) != 0);
    LedCabecaVerde((contcor & 4) != 0);
    LedCabecaVermelho((contcor & 8) != 0);
  }
}

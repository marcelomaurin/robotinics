// Sensores ----------------------------------------------------------------

void Start_acel()
{
  xLastValue = analogRead(pinacelx);
  yLastValue = analogRead(pinacely);
  zLastValue = analogRead(pinacelz);
}

void Carrega_acel()
{
  xValue = analogRead(pinacelx);
  yValue = analogRead(pinacely);
  zValue = analogRead(pinacelz);

  xAcel = xValue - xLastValue;
  yAcel = yValue - yLastValue;
  zAcel = zValue - zLastValue;
}

void Le_ace()
{
  Print("acel:");
  Print(String(xValue));
  Print(",");
  Print(String(yValue));
  Print(",");
  Print(String(zValue));
}

void StartGas()
{
  // Mantido conforme hardware original.
  pinMode(analogOutGas, INPUT);
}

void Carrega_gas()
{
  const int sensorValue1 = analogRead(analogInGas);
  const int sensorValue2 = analogRead(analogInGas);
  const int sensorValue3 = analogRead(analogInGas);
  const int sensorValue = (sensorValue1 + sensorValue2 + sensorValue3) / 3;

  if (sensorValue <= 0) {
    thickness = -20000;
    return;
  }

  thickness = 20000 - (5000 * (1023 / (float)sensorValue) - 1);
}

void Le_gas()
{
  if (thickness < -10812) Println("Nao detectado sensor fumaça");
  else if (thickness < -3462) Println("Indicio sensor fumaça");
  else if (thickness < 1990) Println("Detectado sensor fumaça");
  else Println("Forte sinal sensor fumaça");
}

void Carrega_corr()
{
  const int sensorValue = analogRead(analogInCorr);
  Corrente = map(sensorValue, 0, 1023, -30, 30);
}

void Le_corr()
{
  Carrega_corr();
  Print("Corrente:");
  dtostrf(Corrente, 0, 2, sInfo);
  Println(String(sInfo));
}

static float leituraUltrassomCM(Ultrasonic &sensor, long &microsec)
{
  microsec = sensor.timing();
  return sensor.convert(microsec, Ultrasonic::CM);
}

void Le_Ultrasom(int Imprime)
{
  long microsec = 0;
  const float cmMsec = leituraUltrassomCM(ultrasonic, microsec);
  const float inMsec = ultrasonic.convert(microsec, Ultrasonic::IN);

  cmRe = (int)cmMsec;

  if (Imprime != 0) {
    Print("Cent: ");
    dtostrf(cmMsec, 0, 2, sInfo);
    Print(String(sInfo));
    Print(", Pol. : ");
    dtostrf(inMsec, 0, 2, sInfo);
    Println(String(sInfo));
  }
}

void Le_Ultrasom1(int Imprime)
{
  long microsec = 0;
  const float cmMsec = leituraUltrassomCM(ultrasonic1, microsec);
  const float inMsec = ultrasonic1.convert(microsec, Ultrasonic::IN);

  cmCorpo = (int)cmMsec;

  if (Imprime != 0) {
    Print("Cent: ");
    dtostrf(cmMsec, 0, 2, sInfo);
    Print(String(sInfo));
    Print(", Pol. : ");
    dtostrf(inMsec, 0, 2, sInfo);
    Println(String(sInfo));
  }
}

void Le_Ultrasom2(int Imprime)
{
  long microsec = 0;
  const float cmMsec = leituraUltrassomCM(ultrasonic2, microsec);
  const float inMsec = ultrasonic2.convert(microsec, Ultrasonic::IN);

  // Mantem a variavel usada pelo firmware legado.
  cmCorpo = (int)cmMsec;

  if (Imprime != 0) {
    Print("Cent: ");
    dtostrf(cmMsec, 0, 2, sInfo);
    Print(String(sInfo));
    Print(", Pol. : ");
    dtostrf(inMsec, 0, 2, sInfo);
    Println(String(sInfo));
  }
}

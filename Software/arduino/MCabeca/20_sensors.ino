// Sensor ultrassonico ------------------------------------------------------

void Le_Ultrasom(int Imprime)
{
  float somaCm = 0.0f;
  float somaPol = 0.0f;

  // Mantem as tres amostras originais para compatibilidade do comportamento.
  for (uint8_t i = 0; i < 3; i++)
  {
    const long microsec = ultrasonic.timing();
    somaCm += ultrasonic.convert(microsec, Ultrasonic::CM);
    somaPol += ultrasonic.convert(microsec, Ultrasonic::IN);
  }

  const float cmMsec = somaCm / 3.0f;
  const float inMsec = somaPol / 3.0f;
  cmCabeca = (int)cmMsec;

  if (Imprime == 1)
  {
    Serial.print(F("Cent: "));
    Serial.print(cmMsec);
    Serial.print(F(", Pol. : "));
    Serial.println(inMsec);
  }
  else if (Imprime == 2 && cmMsec < 10.0f)
  {
    Serial.print(F("Colisao eminente Cent: "));
    Serial.print(cmMsec);
    Serial.print(F(", Pol. : "));
    Serial.println(inMsec);
    Prompt();
  }
}

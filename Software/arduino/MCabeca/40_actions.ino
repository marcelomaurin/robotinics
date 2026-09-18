// Acoes mecanicas ----------------------------------------------------------

void SCANNING()
{
  Serial.println(F("Iniciando Varredura"));
  LaserON();

  for (int x = 0; x <= 180; x += 5)
  {
    Point(x, 0);
    delay(400);
    Point(x, 180);
    delay(400);
  }

  Point(90, 0);
  LaserOFF();
}

void TesteMovimento()
{
  Serial.println(F("Iniciando teste de movimento"));

  for (uint8_t cont = 0; cont <= 5; cont++)
  {
    // Corrige a leitura incorreta 'digitalRead(pinOlhos==HIGH)' do firmware antigo.
    LedOlhos(!digitalRead(PIN_OLHOS));

    LedCabecaAzul(true); delay(150);
    LedCabecaVerde(true); delay(150);
    LedCabecaVermelho(true); delay(300);

    LedCabecaAzul(true); delay(150);
    LedCabecaVerde(false); delay(150);
    LedCabecaVermelho(true); delay(300);

    LedCabecaAzul(false); delay(150);
    LedCabecaVerde(true); delay(150);
    LedCabecaVermelho(true); delay(300);

    LedCabecaAzul(true); delay(150);
    LedCabecaVerde(true); delay(150);
    LedCabecaVermelho(false); delay(150);

    LedCabecaAzul(false); delay(150);
    LedCabecaVerde(false); delay(150);
    LedCabecaVermelho(false); delay(150);
  }

  for (uint8_t cont = 0; cont <= 5; cont++)
  {
    LedOlhos(true);
    delay(150);
    LedOlhos(false);
    delay(150);
  }

  LaserON();
  SCANNING();
  LaserOFF();
}

// Protocolo legado + extensoes compativeis com o Mega ---------------------

void Prompt()
{
  Serial.println(F("$>"));
}

void Versao()
{
  Serial.println(F("ROBOTINICS Arduino Driver"));
  Serial.println(F("Criado por Marcelo Maurin Martins"));
  Serial.println(F("Robotinics Driver Cabeca"));
  Serial.print(F("Versão"));
  Serial.println(FVersao);
}

void Help()
{
  Serial.println(F("MAN - Manual de comandos"));
  Serial.println(F("ULTRA - Ultrasom (legado)"));
  Serial.println(F("DIST - Distancia em formato MCAB:DIST"));
  Serial.println(F("VER - Versao do MCabeca"));
  Serial.println(F("LASERON - Liga laser"));
  Serial.println(F("LASEROFF - Desliga laser"));
  Serial.println(F("SCANNING - Varre area com laser"));
  Serial.println(F("POINT:x,y - Posiciona servos"));
  Serial.println(F("GETPOS - Retorna angulos comandados"));
  Serial.println(F("CENTER - Centraliza cabeca"));
  Serial.println(F("LEDAZUL=ON/OFF"));
  Serial.println(F("LEDVERDE=ON/OFF"));
  Serial.println(F("LEDVERMELHO=ON/OFF"));
  Serial.println(F("OLHOS=ON/OFF"));
  Serial.println(F("LIGHTAUTO=ON/OFF"));
  Serial.println(F("TESTE - Teste de Movimento"));
}

static bool equalsCommand(const char *cmd, const char *expected)
{
  return strcmp(cmd, expected) == 0;
}

static bool startsWithCommand(const char *cmd, const char *prefix)
{
  return strncmp(cmd, prefix, strlen(prefix)) == 0;
}

static bool parseOnOff(const char *value, bool &state)
{
  if (strcmp(value, "ON") == 0) {
    state = true;
    return true;
  }

  if (strcmp(value, "OFF") == 0) {
    state = false;
    return true;
  }

  return false;
}

static void respostaOK(const __FlashStringHelper *item, bool state)
{
  Serial.print(F("MCAB:OK:"));
  Serial.print(item);
  Serial.print('=');
  Serial.println(state ? F("ON") : F("OFF"));
}

static void executaPoint(const char *cmd)
{
  const char *params = strchr(cmd, ':');
  if (params == NULL) params = strchr(cmd, '=');
  if (params == NULL) return;

  params++;
  const char *virgula = strchr(params, ',');
  if (virgula == NULL) return;

  const int x = atoi(params);
  const int y = atoi(virgula + 1);

  Point(y, x);

  Serial.print(F("MCAB:POS:"));
  Serial.print(currentX);
  Serial.print(',');
  Serial.println(currentY);
}

static bool executaSaida(const char *cmd,
                         const char *prefix,
                         const __FlashStringHelper *nome,
                         void (*setter)(bool))
{
  if (!startsWithCommand(cmd, prefix)) return false;

  bool state = false;
  const char *value = cmd + strlen(prefix);

  if (!parseOnOff(value, state)) {
    Serial.println(F("MCAB:ERR:VALUE"));
    return true;
  }

  lightAuto = false;
  setter(state);
  respostaOK(nome, state);
  return true;
}

void ExecCMD(const char *pBuffer)
{
  Serial.print(F("Comando:"));
  Serial.println(pBuffer);

  bool flgRum = false;

  if (equalsCommand(pBuffer, "ULTRA"))
  {
    Le_Ultrasom(1);
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "DIST"))
  {
    EnviaDistancia();
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "MAN"))
  {
    Help();
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "TESTE"))
  {
    TesteMovimento();
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "LASERON"))
  {
    LaserON();
    Serial.println(F("MCAB:OK:LASER=ON"));
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "LASEROFF"))
  {
    LaserOFF();
    Serial.println(F("MCAB:OK:LASER=OFF"));
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "VER"))
  {
    Versao();
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "SCANNING"))
  {
    SCANNING();
    flgRum = true;
  }
  else if (startsWithCommand(pBuffer, "POINT:") || startsWithCommand(pBuffer, "POINT="))
  {
    executaPoint(pBuffer);
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "GETPOS"))
  {
    Serial.print(F("MCAB:POS:"));
    Serial.print(currentX);
    Serial.print(',');
    Serial.println(currentY);
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "CENTER"))
  {
    Point(CABECA_Y_HOME, CABECA_X_HOME);
    Serial.print(F("MCAB:POS:"));
    Serial.print(currentX);
    Serial.print(',');
    Serial.println(currentY);
    flgRum = true;
  }
  else if (executaSaida(pBuffer, "LEDAZUL=", F("LEDAZUL"), LedCabecaAzul))
  {
    flgRum = true;
  }
  else if (executaSaida(pBuffer, "LEDVERDE=", F("LEDVERDE"), LedCabecaVerde))
  {
    flgRum = true;
  }
  else if (executaSaida(pBuffer, "LEDVERMELHO=", F("LEDVERMELHO"), LedCabecaVermelho))
  {
    flgRum = true;
  }
  else if (executaSaida(pBuffer, "OLHOS=", F("OLHOS"), LedOlhos))
  {
    flgRum = true;
  }
  else if (startsWithCommand(pBuffer, "LIGHTAUTO="))
  {
    bool state = false;
    if (parseOnOff(pBuffer + 10, state)) {
      lightAuto = state;
      respostaOK(F("LIGHTAUTO"), state);
    } else {
      Serial.println(F("MCAB:ERR:VALUE"));
    }
    flgRum = true;
  }

  if (!flgRum)
  {
    Serial.println(F("Comando não reconhecido"));
  }

  Prompt();
}

void Serial_Read()
{
  while (Serial.available() > 0)
  {
    const char inByte = (char)Serial.read();

    if (inByte == '\r') continue;

    if (inByte == '\n')
    {
      rxBuffer[rxPos] = '\0';

      if (rxPos > 0)
      {
        ExecCMD(rxBuffer);
      }

      rxPos = 0;
      rxBuffer[0] = '\0';
      return;
    }

    if (rxPos < RX_BUFFER_SIZE - 1)
    {
      rxBuffer[rxPos++] = inByte;
      rxBuffer[rxPos] = '\0';
    }
    else
    {
      rxPos = 0;
      rxBuffer[0] = '\0';
    }
  }
}

void Leituras()
{
  Le_Ultrasom(2);
  Serial_Read();
}

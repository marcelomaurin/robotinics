// Protocolo legado ---------------------------------------------------------

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
  Serial.println(F("ULTRA - Ultrasom"));
  Serial.println(F("VER - Versao do MCabeca"));
  Serial.println(F("LASERON - Liga laser"));
  Serial.println(F("LASEROFF - Desliga laser"));
  Serial.println(F("SCANNING - Varre area com laser"));
  Serial.println(F("POINT - Aponta laser posicao POINT=x,y"));
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

static void executaPoint(const char *cmd)
{
  // Mantem POINT: aceito pelo firmware antigo.
  // Tambem aceita POINT= conforme o texto do MAN, sem quebrar compatibilidade.
  const char *params = strchr(cmd, ':');
  if (params == NULL) params = strchr(cmd, '=');
  if (params == NULL) return;

  params++;
  const char *virgula = strchr(params, ',');
  if (virgula == NULL) return;

  const int x = atoi(params);
  const int y = atoi(virgula + 1);

  Point(y, x);
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
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "VER"))
  {
    Versao();
    flgRum = true;
  }
  else if (equalsCommand(pBuffer, "LASEROFF"))
  {
    LaserOFF();
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
      // Protecao contra estouro: descarta a linha excessivamente longa.
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

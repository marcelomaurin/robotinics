// Comunicacao e protocolo legado ------------------------------------------

static const size_t RX_BUFFER_SIZE = 96;
static char usbBuffer[RX_BUFFER_SIZE];
static char bluetoothBuffer[RX_BUFFER_SIZE];
static char arduinoBuffer[RX_BUFFER_SIZE];
static size_t usbPos = 0;
static size_t bluetoothPos = 0;
static size_t arduinoPos = 0;

void Print(String info)
{
  Serial.print(info);
  Serial1.print(info);
}

void Println(String info)
{
  Serial.println(info);
  Serial1.println(info);
}

void ImprimeCursor()
{
  Println("$>");
}

void StartSerial()
{
  Serial.begin(115200);
}

void StartBluetooth()
{
  Serial1.begin(9600);
}

void StartArduino()
{
  mySerial.begin(9600);
}

void StartRC()
{
  mySwitch.enableReceive(PINO_RFRX);
}

void EnviaArduino(String info)
{
  mySerial.println(info);
}

void Ver()
{
  Print("Versão");
  Println(String(FVersao));
}

void Help()
{
  Println("MAN - Manual de comandos");
  Println("RE - Controle de Re");
  Println("PARA - Controle de Parar");
  Println("FRENTE - Controle de Av. Frente");
  Println("GESQ - Controle de Girar Esquerda");
  Println("GDIR - Controle de Girar Direita");
  Println("GGARRADIR - Controle de Girar a Garra Direita");
  Println("GPUNHOESQ - Controle de Girar a PUNHO ESQ");
  Println("CLS: - Limpa Mensagens 1 e 2");
  Println("MSG1: - Mensagem Linha 1");
  Println("MSG2: - Mensagem Linha 2");
  Println("SERIAL: - SERIAL MENSAGEM");
  Println("LCDCLEAR - Limpa tela");
  Println("GPS - GPS List");
  Println("ACEL - Acelerometro");
  Println("ULTRA - Ultrasom Ré");
  Println("ULTRA1 - Ultrasom Frente");
  Println("ULTRA2 - Ultrasom Cabeça");
  Println("GAS - Sensor Gas");
  Println("CORR - Corrente");
  Println("TESTE - Teste de Movimento");
  Println("GBESQ - Gira Braco Esquerdo = Angulo");
  Println("GBDir - Gira Braco Direito = Angulo");
  Println("GPUNHOESQ - Gira Braco Direito = Angulo");
  Println("GCABECADIR - Gira Cabeca para Direita = Angulo");
  Println("GCABECAESQ - Gira Cabeca para Esquerda = Angulo");
  Println("GPGARRADIR - Controle de Girar a Garra Direita = Angulo");
  Println("GPGARRAESQ - Controle de Girar a Garra Esquerda = Angulo");
  Println("GPPUNHOESQ - Controle de Girar a PUNHO ESQ = Angulo");
  Println("GPPUNHODIR - Controle de Girar a PUNHO DIR = Angulo");
  Println("SETMONITOR - Status de monitoramento = ON/OFF");
}

static bool startsWith(const String &value, const char *prefix)
{
  return value.startsWith(prefix);
}

void ExecCMD(String pBuffer)
{
  pBuffer.trim();
  bool flgRodou = false;

  // Comandos simples: correspondencia exata evita colisoes como ULTRA/ULTRA1.
  if (pBuffer == "RE") {
    Re(); flgRodou = true;
  } else if (pBuffer == "PARA") {
    Para(); flgRodou = true;
  } else if (pBuffer == "FRENTE") {
    Frente(); flgRodou = true;
  } else if (pBuffer == "GESQ") {
    GiraEsq(0); flgRodou = true;
  } else if (pBuffer == "GDIR") {
    GiraDir(0); flgRodou = true;
  } else if (pBuffer == "GGARRADIR") {
    GGarraDir(0); flgRodou = true;
  } else if (pBuffer == "GPUNHOESQ") {
    GPUNHOESQ(0); flgRodou = true;
  } else if (pBuffer == "GPUNHODIR") {
    GPUNHODIR(0); flgRodou = true;
  } else if (pBuffer == "CLS") {
    CLS(); Msg01 = ""; Msg02 = ""; flgRodou = true;
  } else if (pBuffer == "LCDCLEAR") {
    CLS(); flgRodou = true;
  } else if (pBuffer == "GPS") {
    Le_GPS(); flgRodou = true;
  } else if (pBuffer == "ACEL") {
    Le_ace(); flgRodou = true;
  } else if (pBuffer == "ULTRA") {
    Le_Ultrasom(1); flgRodou = true;
  } else if (pBuffer == "ULTRA1") {
    Le_Ultrasom1(1); flgRodou = true;
  } else if (pBuffer == "ULTRA2") {
    Le_Ultrasom2(1); flgRodou = true;
  } else if (pBuffer == "GAS") {
    Le_gas(); flgRodou = true;
  } else if (pBuffer == "CORR") {
    Le_corr(); flgRodou = true;
  } else if (pBuffer == "MAN") {
    Help(); flgRodou = true;
  } else if (pBuffer == "VER") {
    Ver(); flgRodou = true;
  } else if (pBuffer == "TESTE") {
    TesteMovimento(); flgRodou = true;
  }

  if (startsWith(pBuffer, "MSG1:")) {
    Msg01 = pBuffer.substring(5);
    Imprime(0, Msg01);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "MSG2:")) {
    Msg02 = pBuffer.substring(5);
    Imprime(1, Msg02);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "SERIAL:")) {
    // substring(5) preservado por compatibilidade com o firmware 1.3.
    EnviaArduino(pBuffer.substring(5));
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GCABECAESQ=")) {
    const int angulo = pBuffer.substring(11).toInt();
    Println(pBuffer.substring(11));
    Println(String(angulo));
    GCabecaEsq(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GCABECADIR=")) {
    const int angulo = pBuffer.substring(11).toInt();
    Println(pBuffer.substring(11));
    Println(String(angulo));
    GCabecaDir(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GBDIR=")) {
    const int angulo = pBuffer.substring(6).toInt();
    Println(pBuffer.substring(6));
    Println(String(angulo));
    GBDir(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GBESQ=")) {
    const int angulo = pBuffer.substring(6).toInt();
    Println(pBuffer.substring(6));
    Println(String(angulo));
    GBEsq(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GPGARRADIR=")) {
    const int angulo = pBuffer.substring(11).toInt();
    Println(pBuffer.substring(11));
    Println(String(angulo));
    GGarraDir(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GPGARRAESQ=")) {
    const int angulo = pBuffer.substring(11).toInt();
    Println(pBuffer.substring(11));
    Println(String(angulo));
    GGARRAESQ(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GPPUNHOESQ=")) {
    const int angulo = pBuffer.substring(11).toInt();
    Println(pBuffer.substring(11));
    Println(String(angulo));
    GPUNHOESQ(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "GPPUNHODIR=")) {
    const int angulo = pBuffer.substring(11).toInt();
    Println(pBuffer.substring(11));
    Println(String(angulo));
    GPUNHODIR(angulo);
    flgRodou = true;
  }

  if (startsWith(pBuffer, "SETMONITOR=")) {
    const String status = pBuffer.substring(11);
    if (status == "ON") SETMONITOR(true);
    if (status == "OFF") SETMONITOR(false);
    flgRodou = true;
  }

  if (!flgRodou) Println("Comando não reconhecido!");
}

static void receiveCommand(Stream &port, char *buffer, size_t &pos)
{
  while (port.available() > 0) {
    const char c = (char)port.read();

    if (c == '\r') continue;

    if (c == '\n') {
      buffer[pos] = '\0';
      if (pos > 0) {
        ExecCMD(String(buffer));
        ImprimeCursor();
      }
      pos = 0;
      buffer[0] = '\0';
      return;
    }

    if (pos < RX_BUFFER_SIZE - 1) {
      buffer[pos++] = c;
      buffer[pos] = '\0';
    } else {
      // descarta linha longa de forma segura, sem escrever alem do buffer
      pos = 0;
      buffer[0] = '\0';
    }
  }
}

void Le_Arduino()
{
  receiveCommand(mySerial, arduinoBuffer, arduinoPos);
}

void Le_Bluetooth()
{
  receiveCommand(Serial1, bluetoothBuffer, bluetoothPos);
}

void Le_Serial()
{
  receiveCommand(Serial, usbBuffer, usbPos);
}

void Carrega_RC()
{
  if (!mySwitch.available()) return;

  const unsigned long value = mySwitch.getReceivedValue();

  if (value == 0) {
    Serial.print("Unknown encoding");
  } else {
    Serial.print("Received ");
    Serial.print(value);
    Serial.print(" / ");
    Serial.print(mySwitch.getReceivedBitlength());
    Serial.print("bit ");
    Serial.print("Protocol: ");
    Serial.println(mySwitch.getReceivedProtocol());
  }

  mySwitch.resetAvailable();
}

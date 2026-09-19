// LCD e apresentacao ---------------------------------------------------------

uint8_t bell[8]  = {0x4, 0xe, 0xe, 0xe, 0x1f, 0x0, 0x4};
uint8_t note[8]  = {0x2, 0x3, 0x2, 0xe, 0x1e, 0xc, 0x0};
uint8_t clockc[8]= {0x0, 0xe, 0x15, 0x17, 0x11, 0xe, 0x0};
uint8_t heart[8] = {0x0, 0xa, 0x1f, 0x1f, 0xe, 0x4, 0x0};
uint8_t duck[8]  = {0x0, 0xc, 0x1d, 0xf, 0xf, 0x6, 0x0};
uint8_t checkc[8]= {0x0, 0x1, 0x3, 0x16, 0x1c, 0x8, 0x0};
uint8_t cross[8] = {0x0, 0x1b, 0xe, 0x4, 0xe, 0x1b, 0x0};
uint8_t retarrow[8]={0x1, 0x1, 0x5, 0x9, 0x1f, 0x8, 0x4};

void CLS()
{
  lcd.clear();
}

void Imprime(int Linha, String Msg)
{
  lcd.setCursor(0, Linha);
  lcd.print(Msg);
}

void Start_lcd()
{
  lcd.init();
  lcd.status();
  CLS();
  Imprime(0, "ROBOTINICS");
  Imprime(1, "Load");

  lcd.createChar(0, bell);
  lcd.createChar(1, note);
  lcd.createChar(2, clockc);
  lcd.createChar(3, heart);
  lcd.createChar(4, duck);
  lcd.createChar(5, checkc);
  lcd.createChar(6, cross);
  lcd.createChar(7, retarrow);
  lcd.home();
}

void StartWelcomme()
{
  Println("ROBOTINICS Arduino Driver");
  Println("Criado por Marcelo Maurin Martins");
  Print("Robotinics V.");
  Println(FVersao);

  CLS();
  Imprime(0, "ROBOTINICS");
  Imprime(1, "V." + String(FVersao));
  ImprimeCursor();
}

void SETMONITOR(bool Status)
{
  flgMonitor = Status;
}

void Carrega_Monitor()
{
  if (!flgMonitor) return;

  intMonitor++;

  if (intMonitor == 1) {
    CLS();
    Imprime(0, "Robotinics ");
    Imprime(1, "V." + String(FVersao));
  } else if (intMonitor == 100) {
    CLS();
    Imprime(0, "Corrente");
    dtostrf(Corrente, 0, 2, sInfo);
    Imprime(1, String(sInfo) + "A");
  } else if (intMonitor == 200) {
    CLS();
    Imprime(0, "Tensao");
    Imprime(1, "12V");
  } else if (intMonitor == 300) {
    CLS();
    Imprime(0, "GAS");
    if (thickness < -10812) Imprime(1, "Nao identific");
    else if (thickness < -3462) Imprime(1, "Indicio");
    else if (thickness < 1990) Imprime(1, "Detectado");
    else Imprime(1, "Forte");
  } else if (intMonitor == 400) {
    CLS();
    Imprime(0, "Acelerometro");
    Imprime(1, "X:" + String(xValue) + "Y:" + String(yValue) + "Z:" + String(zValue));
  } else if (intMonitor == 500) {
    CLS();
    Imprime(0, "Status");
    if (Is_FRENTE()) Imprime(1, "Avanco");
    else if (Is_RE()) Imprime(1, "Re");
    else Imprime(1, "Parado");
  } else if (intMonitor == 600) {
    CLS();
    Imprime(0, Msg01);
    Imprime(1, Msg02);
  }

  if (intMonitor >= 900) intMonitor = 0;
}

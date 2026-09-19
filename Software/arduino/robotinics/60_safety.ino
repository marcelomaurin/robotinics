// Seguranca ---------------------------------------------------------------

void fMargem(bool flgView)
{
  if (Is_RE() && cmRe < Margem) {
    if (flgView) {
      Print("Margem Seguranca RE ");
      Println(String(cmRe) + " cm");
    }
    Para();
  }

  if (Is_FRENTE() && cmCorpo < Margem) {
    if (flgView) {
      Print("Margem Seguranca da Frente ");
      Println(String(cmCorpo) + " cm");
    }
    Para();
  }
}

void Leituras()
{
  Le_Ultrasom(0);
  Le_Ultrasom1(0);

  Le_Arduino();
  Le_Bluetooth();
  Le_Serial();

  Carrega_gas();
  Carrega_corr();
  Carrega_acel();
  Carrega_RC();

  // Carrega_Monitor permanece desabilitado como no firmware 1.3.
  fMargem(true);
}

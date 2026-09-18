// Servos -----------------------------------------------------------------

static const uint8_t CABECA_HOME = 90;
static const uint8_t BRACO_DIR_HOME = 0;
static const uint8_t MAO_DIR_HOME = 155;
static const uint8_t BRACO_ESQ_HOME = 166;
static const uint8_t GARRA_ESQ_HOME = 7;
static const uint8_t PUNHO_ESQ_HOME = 90;

void Start_Cabeca()    { Cabeca.attach(pinCabeca);       Cabeca.write(CABECA_HOME); }
void Start_Garra()     { GarraDIR.attach(pinGARRADIR);   GarraDIR.write(90); }
void Start_BDireito()  { BDireito.attach(pinBDireito);   BDireito.write(BRACO_DIR_HOME); }
void Start_BEsquerdo() { BEsquerdo.attach(pinBEsquerdo); BEsquerdo.write(BRACO_ESQ_HOME); }
void Start_GARRAESQ()  { GARRAESQ.attach(pinGARRAESQ);   GARRAESQ.write(GARRA_ESQ_HOME); }
void Start_MDireita()  { MDireita.attach(pinMDireita);   MDireita.write(MAO_DIR_HOME); }
void Start_PEsquerdo() { PEsquerdo.attach(pinPEsquerdo); PEsquerdo.write(PUNHO_ESQ_HOME); }

void GCabecaDir(int Percentual)
{
  Cabeca.write(constrain(map(Percentual, 0, 90, 90, 180), 0, 180));
}

void GCabecaEsq(int Percentual)
{
  Cabeca.write(constrain(map(Percentual, 0, 90, 90, 0), 0, 180));
}

void GGarraDir(int Percentual)
{
  // Mantem a conversao original do protocolo.
  GarraDIR.write(constrain(map(Percentual, 0, 90, 90, 180), 0, 180));
}

void GBDir(int Percentual)
{
  BDireito.write(constrain(map(Percentual, 0, 180, 0, 180), 0, 180));
}

void GBEsq(int Percentual)
{
  BEsquerdo.write(constrain(map(Percentual, 0, 180, 166, 2), 0, 180));
}

void GGARRAESQ(int Percentual)
{
  GARRAESQ.write(constrain(map(Percentual, 0, 180, 7, 150), 0, 180));
}

void GPUNHODIR(int Percentual)
{
  MDireita.write(constrain(map(Percentual, 0, 180, 180, 0), 0, 180));
}

void GPUNHOESQ(int Percentual)
{
  PEsquerdo.write(constrain(map(Percentual, 0, 180, 180, 0), 0, 180));
}

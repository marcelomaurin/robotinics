// GPS --------------------------------------------------------------------

int byteGPS = -1;
char linea[300] = "";
const char comandoGPR[7] = "$GPRMC";
int indices[13];

void Start_GPS()
{
  Serial3.begin(4800);
}

void Le_GPS()
{
  static uint16_t conta = 0;

  while (Serial3.available() > 0) {
    byteGPS = Serial3.read();

    if (conta >= sizeof(linea) - 1) {
      conta = 0; // protege contra overflow mantendo o parser operacional
    }

    linea[conta++] = (char)byteGPS;
    linea[conta] = '\0';

    if (byteGPS != 13) continue;

    int bien = 0;
    for (int i = 1; i < 7 && i < conta; i++) {
      if (linea[i] == comandoGPR[i - 1]) bien++;
    }

    if (bien == 6) {
      int cont = 0;
      for (uint16_t i = 0; i < conta && cont < 13; i++) {
        if (linea[i] == ',' && cont < 12) {
          indices[cont++] = i;
        } else if (linea[i] == '*') {
          indices[12] = i;
        }
      }

      Println("");
      Println("");
      Println("---------------");

      static const char *labels[12] = {
        "Time in UTC (HhMmSs): ",
        "Status (A=OK,V=KO): ",
        "Latitude: ",
        "Direction (N/S): ",
        "Longitude: ",
        "Direction (E/W): ",
        "Velocity in knots: ",
        "Heading in degrees: ",
        "Date UTC (DdMmAa): ",
        "Magnetic degrees: ",
        "(E/W): ",
        "Mode: "
      };

      for (int i = 0; i < 12; i++) {
        Print(labels[i]);
        const int startPos = indices[i] + 1;
        const int endPos = indices[i + 1];
        if (startPos >= 0 && endPos > startPos && endPos <= (int)conta) {
          for (int j = startPos; j < endPos; j++) Print(String(linea[j]));
        }
        Println("");
      }

      Println("---------------");
      conta = 0;
      linea[0] = '\0';
      return;
    }

    conta = 0;
    linea[0] = '\0';
  }
}

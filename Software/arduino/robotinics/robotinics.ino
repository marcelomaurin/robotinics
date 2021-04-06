#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Ultrasonic.h>     //Carrega a biblioteca Ultrasonic
#include <Servo.h>
#include <RCSwitch.h>

char FVersao[10] = "1.3";

LiquidCrystal_I2C lcd(0x20, 16, 2); // set the LCD address to 0x20 for a 16 chars and 2 line display

Servo Cabeca;  // create servo object to control a servo
Servo BDireito;  // create servo object to control a servo
Servo MDireita;  // create servo object to control a servo
Servo BEsquerdo;  // create servo object to control a servo
Servo PEsquerdo;
Servo GARRAESQ;
Servo GarraDIR;

//Partes
int pinCabeca = 6;
int pinBDireito = 44;
int pinMDireita = 8;
int pinBEsquerdo = 9;
int pinGARRAESQ = 10;
int pinGARRADIR = 11;
int pinPEsquerdo = 46;
//int pinBDireito = 12;
int pinVoltagem = A6;
int pinacelx = A1;
int pinacely = A2;
int pinacelz = A3;

//gas
int analogInGas = A4;  // Analog input pin that the potentiometer is attached to
int analogOutGas = A5; // Analog output pin that the LED is attached to
float Corrente = 0;
int analogInCorr = A0;

//Motor 
#define PINO_ENA  26
#define PINO_IN1  28
#define PINO_IN2  30
#define PINO_IN3  34
#define PINO_IN4  32
#define PINO_ENB  36

#define PINO_RFRX  17 //Pino radio frequencia receive3 RX2
#define PINO_RFTX  16 //Pino radio frequencia receive3 TX2
#define PINO_TRIGGER  2 //Define o pino do Arduino a ser utilizado com o pino Trigger do sensor
#define PINO_ECHO     3 //Define o pino do Arduino a ser utilizado com o pino Echo do sensor
#define PINO_TRIGGER1  40 //Define o pino do Arduino a ser utilizado com o pino Trigger do sensor
#define PINO_ECHO1     35 //Define o pino do Arduino a ser utilizado com o pino Echo do sensor
#define PINO_TRIGGER2  41 //Define o pino do Arduino a ser utilizado com o pino Trigger do sensor
#define PINO_ECHO2     42 //Define o pino do Arduino a ser utilizado com o pino Echo do sensor
#define Arduino2TX  38 //Define o pino do Arduino a ser utilizado com o pino Trigger do sensor
#define Arduino2RX    37 //Define o pino do Arduino a ser utilizado com o pino Echo do sensor
//int rxPin = 0;                   
//int txPin = 1;                    // TX TX
#define PINOGPSRX = 0;  // RX PIN
#define PINOGPSTX = 1;  // TX TX
Ultrasonic ultrasonic(PINO_TRIGGER, PINO_ECHO); //Inicializa o sensor ultrasonico Ré
Ultrasonic ultrasonic1(PINO_TRIGGER1, PINO_ECHO1); //Inicializa o sensor ultrasonico Frente
Ultrasonic ultrasonic2(PINO_TRIGGER2, PINO_ECHO2); //Inicializa o sensor ultrasonico Cabeca

#if ARDUINO >= 100
#include <SoftwareSerial.h>
#else
#include <NewSoftSerial.h>
#endif
// pin #2 is IN from sensor (GREEN wire)
// pin #3 is OUT from arduino  (WHITE wire)
#if ARDUINO >= 100
SoftwareSerial mySerial(Arduino2TX, Arduino2RX);
#else
NewSoftSerial mySerial(Arduino2TX, Arduino2RX);
#endif

int cmRe, cmCorpo;
int Margem = 20; //Margem de segurança para nao bater


//gps

int byteGPS = -1;
char linea[300] = "";
char comandoGPR[7] = "$GPRMC";
int cont = 0;
int bien = 0;
int conta = 0;
int indices[13];

RCSwitch mySwitch = RCSwitch();
//variaveis acelerometro
int xValue, xLastValue ;
int yValue, yLastValue;
int zValue , zLastValue;

float xAcel,yAcel, zAcel;

String Buffer;
char inByte;
String Info; //Variavel de uso geral
bool flgMonitor = true;
float thickness;
int intMonitor = 0;

String Msg01;
String Msg02;
char sInfo[255];  //variavel de uso geral
  
//Imprime sem quebra
void Print(String info)
{
  Serial.print(info);
  Serial1.print(info);
}

//Imprime com quebra
void Println(String info)
{
  Serial.println(info);
  Serial1.println(info);
}

void StartWelcomme()
{
  Println("ROBOTINICS Arduino Driver");
  Println("Criado por Marcelo Maurin Martins");
  Print("Robotinics V.");
  Println(FVersao);
  CLS();
  Imprime(0, "ROBOTINICS");
  Imprime(1, "V."+String(FVersao));

  ImprimeCursor();
  
}

void StartRC()
{
  mySwitch.enableReceive(PINO_RFRX);  // Receiver on inerrupt 0 => that is pin #2  
}

void StartSerial()
{
  //initialize serial:
  Serial.begin(115200);
}

void StartBluetooth()
{
  //initialize serial:
  Serial1.begin(9600);
}

//Inicializa comunicacao com Arduino UNO
void StartArduino()
{
  mySerial.begin(9600);
}

void Start_Cabeca()
{
  Cabeca.attach(pinCabeca);  // attaches the servo on pin 9 to the servo object
  Cabeca.write(90);
}


void Start_Garra()
{
  GarraDIR.attach(pinGARRADIR);  // attaches the servo on pin 9 to the servo object
  GarraDIR.write(90);
}


void Start_BDireito()
{
  BDireito.attach(pinBDireito);  // attaches the servo on pin 9 to the servo object
  BDireito.write(0);
}

void Start_BEsquerdo()
{
  BEsquerdo.attach(pinBEsquerdo);  // attaches the servo on pin 9 to the servo object
  BEsquerdo.write(166);
}

void Start_GARRAESQ()
{
  GARRAESQ.attach(pinGARRAESQ);  // attaches the servo on pin 10 to the servo object
  GARRAESQ.write(7);
}


void Start_MDireita()
{
  MDireita.attach(pinMDireita);  // attaches the servo on pin 9 to the servo object
  MDireita.write(155);
}

void Start_PEsquerdo()
{
  PEsquerdo.attach(pinPEsquerdo);  // attaches the servo on pin 9 to the servo object
  PEsquerdo.write(90);
}

void Start_GPS()
{
  Serial3.begin(4800);
}

void StartMotor()
{
  pinMode(PINO_ENA, OUTPUT);
  pinMode(PINO_ENB, OUTPUT);
  pinMode(PINO_IN1, OUTPUT);
  pinMode(PINO_IN2, OUTPUT);
  pinMode(PINO_IN3, OUTPUT);
  pinMode(PINO_IN4, OUTPUT);
}


void StartGas()
{
  pinMode(analogOutGas, INPUT);
}

//simbolos lcd
uint8_t bell[8]  = {
  0x4, 0xe, 0xe, 0xe, 0x1f, 0x0, 0x4
};
uint8_t note[8]  = {
  0x2, 0x3, 0x2, 0xe, 0x1e, 0xc, 0x0
};
uint8_t clock[8] = {
  0x0, 0xe, 0x15, 0x17, 0x11, 0xe, 0x0
};
uint8_t heart[8] = {
  0x0, 0xa, 0x1f, 0x1f, 0xe, 0x4, 0x0
};
uint8_t duck[8]  = {
  0x0, 0xc, 0x1d, 0xf, 0xf, 0x6, 0x0
};
uint8_t check[8] = {
  0x0, 0x1, 0x3, 0x16, 0x1c, 0x8, 0x0
};
uint8_t cross[8] = {
  0x0, 0x1b, 0xe, 0x4, 0xe, 0x1b, 0x0
};
uint8_t retarrow[8] = {
  0x1, 0x1, 0x5, 0x9, 0x1f, 0x8, 0x4
};

void Start_acel()
{
  xLastValue = analogRead(pinacelx);
  yLastValue = analogRead(pinacely);
  zLastValue = analogRead(pinacelz);
}

void Carrega_acel()
{
  xValue = analogRead(pinacelx);
  xAcel = xValue-xLastValue;  
  yValue = analogRead(pinacely);
  yAcel = yValue-yLastValue;    
  zValue = analogRead(pinacelz);
  zAcel = zValue-zLastValue; 
 /* 
  //if ((xAcel >1.01) )
  {
    //&&(yAcel!=0) &&(zAcel!=0)
    CLS();
    Imprime(0, "X:"+String(xAcel)+" Y:"+String(yAcel));
    Imprime(1, "Z:"+String(zAcel));    
    delay(100);
  }
  */  
}


void Start_lcd()
{
  lcd.init();                      // initialize the lcd
  //delay(300);
  lcd.status();
  //delay(300);
  CLS();
  //delay(300);
  Imprime(0, "ROBOTINICS");
  Imprime(1, "Load...");
  // Print a message to the LCD.
  //lcd.backlight();
  //lcd.status();
  //lcd.setBacklight(255);
  //delay(2000);
  /*
  for (int a=0; a>=255;a++)
  {
    lcd.setBacklight(a);
    delay(300);
  }
  //delay(1000);
  for (int a=0; a>=255;a++)
  {
    lcd.setContrast(a);
    delay(300);
  }
  delay(500);
  */
  //lcd.on();
  //delay(500);
  //lcd.off();
  //delay(500);
  //lcd.on();
  Imprime(0, "ROBOTINICS");
  Imprime(1, "Load");
  lcd.createChar(0, bell);
  lcd.createChar(1, note);
  lcd.createChar(2, clock);
  lcd.createChar(3, heart);
  lcd.createChar(4, duck);
  lcd.createChar(5, check);
  lcd.createChar(6, cross);
  lcd.createChar(7, retarrow);
  lcd.home();
}

void setup() {

  StartSerial();
  StartArduino();
  StartBluetooth();
  Start_lcd();  


  Start_GPS();
  CLS();
  Imprime(0, "Posicionando");
  Imprime(1, "corpo");


  //Posiciona Corpo
  Start_Cabeca();
  //Start_Garra();
  Start_BDireito();
  Start_MDireita();
  Start_BEsquerdo();
  Start_GARRAESQ();
  Start_PEsquerdo();


  StartMotor();
  Start_acel();
  StartGas();

  Buffer = "";
  //Le_corr(); 
  StartWelcomme();
  //TesteMovimento();
}

void SETMONITOR(bool Status)
{
  flgMonitor = Status;
}

void ImprimeCursor()
{
  Println("$>");
}

void Liga()
{
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, LOW);
  digitalWrite(PINO_ENA, HIGH); // Activer moteur A
  digitalWrite(PINO_ENB, HIGH); // Activer moteur B

}

void Para()
{
  digitalWrite(PINO_ENA, LOW); // Activer moteur A
  digitalWrite(PINO_ENB, LOW); // Activer moteur B
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, LOW);

}

//Verifica se esta Avancando
bool Is_FRENTE()
{
  bool flgIN1 = digitalRead(PINO_IN1) == 0;
  bool flgIN2 = digitalRead(PINO_IN2) != 0;
  bool flgIN3 = digitalRead(PINO_IN3) == 0;
  bool flgIN4 = digitalRead(PINO_IN4) != 0;
  bool flgENA = digitalRead(PINO_ENA) != 0;
  bool flgENB = digitalRead(PINO_ENB) != 0;
  bool resultado = flgIN1 && flgIN2 && flgIN3 && flgIN4 && flgENA & flgENB;
  return resultado;
}

void Frente()
{
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, HIGH);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, HIGH);
  digitalWrite(PINO_ENA, HIGH); // Activer moteur A
  digitalWrite(PINO_ENB, HIGH); // Activer moteur B
}

//Verifica se esta em re
bool Is_RE()
{
  bool flgIN1 = digitalRead(PINO_IN1) != 0;
  bool flgIN2 = digitalRead(PINO_IN2) == 0;
  bool flgIN3 = digitalRead(PINO_IN3) != 0;
  bool flgIN4 = digitalRead(PINO_IN4) == 0;
  bool flgENA = digitalRead(PINO_ENA) != 0;
  bool flgENB = digitalRead(PINO_ENB) != 0;
  bool resultado = flgIN1 && flgIN2 && flgIN3 && flgIN4 && flgENA & flgENB;
  return resultado;
}

void Re()
{
  digitalWrite(PINO_IN1, HIGH);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, HIGH);
  digitalWrite(PINO_IN4, LOW);
  digitalWrite(PINO_ENA, HIGH); // Activer moteur A
  digitalWrite(PINO_ENB, HIGH); // Activer moteur B
}

void GiraDir(int Angulo)
{
  digitalWrite(PINO_IN1, HIGH);
  digitalWrite(PINO_IN2, LOW);
  digitalWrite(PINO_IN3, LOW);
  digitalWrite(PINO_IN4, HIGH);
  digitalWrite(PINO_ENA, HIGH); // Activer moteur A
  digitalWrite(PINO_ENB, HIGH); // Activer moteur B

}


void GiraEsq(int Angulo)
{
  digitalWrite(PINO_IN1, LOW);
  digitalWrite(PINO_IN2, HIGH);
  digitalWrite(PINO_IN3, HIGH);
  digitalWrite(PINO_IN4, LOW);
  digitalWrite(PINO_ENA, HIGH); // Activer moteur A
  digitalWrite(PINO_ENB, HIGH); // Activer moteur B
}

void Carrega_gas()
{
  int sensorValue = 0;        // value read from the pot
  int sensorValue1 = 0;        // value read from the pot
  int sensorValue2 = 0;        // value read from the pot
  int sensorValue3 = 0;        // value read from the pot
  byte outputValue;

  // read the analog in value:
  sensorValue1 = analogRead(analogInGas);
  sensorValue2 = analogRead(analogInGas);
  sensorValue3 = analogRead(analogInGas);

  sensorValue =   (sensorValue1 + sensorValue2 + sensorValue3) / 3;
  // map it to the range of the analog out:
  outputValue = map(sensorValue, 0, 1023, 0, 255);
  thickness = 20000 - (5000 * (1023 / (float)sensorValue) - 1); //This relationship is wrong,According to demand, own calculations relationship
}

void Le_gas()
{
  // print the results to the serial monitor:
  //Serial.print("sensor = " );
  //Serial.print(sensorValue);
  //Serial.print("\t output = ");
  //Serial.println(outputValue);


  if (thickness < -10812)
  {
    Println("Nao detectado sensor fumaça");
  }
  if ((thickness > -10812) && (thickness < -3462))
  {
    Println("Indicio sensor fumaça");
  }

  if ((thickness > -3462) && (thickness < 1990))
  {
    Println("Detectado sensor fumaça");
  }

  if ((thickness > 1990))
  {
    Println("Forte sinal sensor fumaça");
  }
}


void Carrega_corr()
{
  int sensorValue = 0;        // value read from the pot
  int outputValue;

  // read the analog in value:
  sensorValue = analogRead(analogInCorr);
  // map it to the range of the analog out:
  Corrente = map(sensorValue, 0, 1023, -30, 30);
}

void Le_corr()
{
  Carrega_corr();
  //This relationship is wrong,According to demand, own calculations relationship
  Print("Corrente:");

  sprintf(sInfo,"%f",Corrente);
  Println(String(Info));
  //Println(String(Corrente));
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


void Le_ace()
{
  Print("acel:");
  Print(String(xValue));
  Print(",");
  Print(String(yValue));
  Print(",");
  Print(String(zValue));

}

void Imprime(int Linha, String Msg)
{
  //lcd.clear();
  lcd.setCursor(0, Linha);
  lcd.print(Msg);
}

void GCabecaDir(int Percentual)
{
  int Angulo = map(Percentual, 0, 90, 90, 180);
  Cabeca.write(Angulo);
}


void GGarraDir(int Percentual)
{
  int Angulo = map(Percentual, 0, 90, 90, 180);
  GarraDIR.write(Angulo);
}


void GCabecaEsq(int Percentual)
{
  int Angulo = map(Percentual, 0, 90, 90, 0);
  Cabeca.write(Angulo);
}

void GBDir(int Percentual)
{
  int Angulo = map(Percentual, 0, 180, 0, 180);
  BDireito.write(Angulo);
}

void GBEsq(int Percentual)
{
  int Angulo = map(Percentual, 0, 180, 166, 2);
  BEsquerdo.write(Angulo);
}

void GGARRAESQ(int Percentual)
{
  int Angulo = map(Percentual, 0, 180, 7, 150);
  GARRAESQ.write(Angulo);
}


//MDireita
//Gira punho Direito
void GPUNHODIR(int Percentual)
{
  int Angulo = map(Percentual, 0, 180, 180, 0);
  MDireita.write(Angulo);
}

//Gira punho Direito
void GPUNHOESQ(int Percentual)
{
  int Angulo = map(Percentual, 0, 180, 180, 0);
  PEsquerdo.write(Angulo);
}


void CLS()
{
  lcd.clear();
}

void ExecCMD(String pBuffer)
{
  bool flgRodou = false;
  if (pBuffer == "RE")
  {
    Re();
    //Serial.print("Re ");
    flgRodou = true;

  }
  if (pBuffer == "PARA")
  {
    Para();
    //Serial.print("Para ");
    flgRodou = true;
  }

  if (pBuffer == "FRENTE")
  {
    Frente();
    //Serial.print("Frente ");
    flgRodou = true;
  }

  if (pBuffer == "GESQ")
  {
    GiraEsq(0);
    //Serial.print("Gira Esquerda ");
    flgRodou = true;
  }

  if (pBuffer == "GGARRADIR")
  {
    GGarraDir(0);
    //Serial.print("Gira Garra ");
    flgRodou = true;
  }

  //GPUNHOESQ
  if (pBuffer == "GPUNHOESQ")
  {
    GPUNHOESQ(0);
    //Serial.print("Gira Garra ");
    flgRodou = true;
  }

  //GPUNHODIR
  if (pBuffer == "GPUNHODIR")
  {
    GPUNHODIR(0);
    //Serial.print("Gira Garra ");
    flgRodou = true;
  }

  if (pBuffer == "GDIR")
  {
    GiraDir(0);
    //Serial.print("Gira Direita ");
    flgRodou = true;
  }
  if (pBuffer == "CLS")
  {
    CLS();
    //Serial.print("Gira Direita ");
    Msg01 = "";
    Msg02 = "";
    flgRodou = true;
  }
  //Serial.print(pBuffer.indexOf("MSG"));
  if (pBuffer.indexOf("MSG1:") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 0);
    //lcd.print(pBuffer.substring(5));
    Msg01 = pBuffer.substring(5);
    Imprime(0, Msg01);
    //Serial.print("MSG1:");
    flgRodou = true;
  }
  //Serial.print(pBuffer.indexOf("MSG"));
  if (pBuffer.indexOf("SERIAL:") >= 0)
  {
    EnviaArduino(pBuffer.substring(5));
    flgRodou = true;
  }

  if (pBuffer.indexOf("MSG2:") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    //lcd.print(pBuffer.substring(5));
    Msg02 = pBuffer.substring(5);
    Imprime(1, Msg02);
    //Serial.print("MSG2:");
    flgRodou = true;
  }

  if (pBuffer.indexOf("GCABECAESQ=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    int Angulo = pBuffer.substring(11).toInt();
    Println(String(pBuffer.substring(11)));
    Println(String(pBuffer.substring(11).toInt()));
    GCabecaEsq(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }
  //GPUNHOESQ
  if (pBuffer.indexOf("GPPUNHOESQ=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    int Angulo = pBuffer.substring(11).toInt();
    Println(String(pBuffer.substring(11)));
    Println(String(pBuffer.substring(11).toInt()));
    GPUNHOESQ(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }

  //GPUNHODIR
  if (pBuffer.indexOf("GPPUNHODIR=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    int Angulo = pBuffer.substring(11).toInt();
    Println(String(pBuffer.substring(11)));
    Println(String(pBuffer.substring(11).toInt()));
    GPUNHODIR(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }

  if (pBuffer.indexOf("GCABECADIR=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    //lcd.print(pBuffer.substring(5));
    int Angulo = pBuffer.substring(11).toInt();
    Println(String(pBuffer.substring(11)));
    Println(String(pBuffer.substring(11).toInt()));
    GCabecaDir(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }

  //GBDir
  if (pBuffer.indexOf("GBDIR=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    //lcd.print(pBuffer.substring(5));
    int Angulo = pBuffer.substring(6).toInt();
    Println(String(pBuffer.substring(6)));
    Println(String(pBuffer.substring(6).toInt()));
    GBDir(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }
  //GBEsq
  if (pBuffer.indexOf("GBESQ=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    //lcd.print(pBuffer.substring(5));
    int Angulo = pBuffer.substring(6).toInt();
    Println(String(pBuffer.substring(6)));
    Println(String(pBuffer.substring(6).toInt()));
    GBEsq(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }

  if (pBuffer.indexOf("GPGARRADIR=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    int Angulo = pBuffer.substring(11).toInt();
    Println(String(pBuffer.substring(11)));
    Println(String(pBuffer.substring(11).toInt()));
    GGarraDir(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }
  
  //GGARRAESQ
  if (pBuffer.indexOf("GPGARRAESQ=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    //lcd.print(pBuffer.substring(5));
    int Angulo = pBuffer.substring(11).toInt();
    Println(String(pBuffer.substring(11)));
    Println(String(pBuffer.substring(11).toInt()));
    GGARRAESQ(Angulo);
    //Serial.print("MSG2:");
    flgRodou = true;
  }  
  if (pBuffer.indexOf("SETMONITOR=") >= 0)
  {
    //lcd.clear();
    //lcd.setCursor(0, 1);
    //lcd.print(pBuffer.substring(5));
    int Angulo = pBuffer.substring(6).toInt();
    Println(String(pBuffer.substring(6)));
    Println(String(pBuffer.substring(6).toInt()));
    //GBEsq(Angulo);
    if (pBuffer.substring(11) == "ON")
    {
      SETMONITOR(true);
    }
    if (pBuffer.substring(11) == "OFF")
    {
      SETMONITOR(false);
    }

    //Serial.print("MSG2:");
    flgRodou = true;
  }



  if (pBuffer.indexOf("LCDCLEAR") >= 0)
  {
    //lcd.clear();
    lcd.clear();
    //Serial.print("LCDCLEAR");
    flgRodou = true;
  }

  if (pBuffer.indexOf("GPS") >= 0)
  {
    //lcd.clear();
    Le_GPS();
    //Serial.print("GPS");
    flgRodou = true;
  }

  if (pBuffer.indexOf("ACEL") >= 0)
  {
    //lcd.clear();
    Le_ace();
    //Serial.print("ACEL");
    flgRodou = true;
  }

  if (pBuffer.indexOf("ULTRA") >= 0)
  {
    //lcd.clear();
    Le_Ultrasom(1);
    //Serial.print("ULTRA");
    flgRodou = true;
  }

  if (pBuffer.indexOf("ULTRA1") >= 0)
  {
    //lcd.clear();
    Le_Ultrasom1(1);
    //Serial.print("ULTRA");
    flgRodou = true;
  }

  if (pBuffer.indexOf("ULTRA2") >= 0)
  {
    //lcd.clear();
    Le_Ultrasom2(1);
    //Serial.print("ULTRA");
    flgRodou = true;
  }


  if (pBuffer.indexOf("GAS") >= 0)
  {
    //lcd.clear();
    Le_gas();
    //Serial.println("GAS");
    flgRodou = true;
  }
  if (pBuffer.indexOf("CORR") >= 0)
  {
    //lcd.clear();
    Le_corr();
    //Serial.println("CORR");
    flgRodou = true;
  }
  if (pBuffer.indexOf("MAN") >= 0)
  {
    //lcd.clear();
    Help();
    //Serial.println("CORR");
    flgRodou = true;
  }
  if (pBuffer.indexOf("VER") >= 0)
  {
    Ver();
    flgRodou = true;
  }
  //TesteMovimento
  if (pBuffer.indexOf("TESTE") >= 0)
  {
    //lcd.clear();
    TesteMovimento();
    //Serial.println("CORR");
    flgRodou = true;
  }
  if (flgRodou == false)
  {
    Println("Comando não reconhecido!");
  }
}

void Le_Ultrasom(int Imprime)
{
  float cmMsec, inMsec;
  float cmMsec1, cmMsec2, cmMsec3;

  long microsec = ultrasonic.timing();  //Le os dados do sensor, com o tempo de retorno do sinal

  cmMsec1 = ultrasonic.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  cmMsec2 = ultrasonic.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  cmMsec3 = ultrasonic.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros  
  cmMsec = (cmMsec1 + cmMsec2 + cmMsec3) / 3;
  
  inMsec = ultrasonic.convert(microsec, Ultrasonic::IN); //Calcula a distancia em polegadas
  cmRe = cmMsec;
  if (Imprime != 0)
  {
    Print("Cent: ");
    sprintf(sInfo,"%f",cmMsec);
    Print(String(sInfo));
    //Print(cmMsec);
    Print(", Pol. : ");
    sprintf(sInfo,"%f",inMsec); 
    Println(String(sInfo));
  }
}

void Le_Ultrasom1(int Imprime)
{
  float cmMsec, inMsec;
  float cmMsec1, cmMsec2, cmMsec3;
  long microsec = ultrasonic1.timing();  //Le os dados do sensor, com o tempo de retorno do sinal

  cmMsec1 = ultrasonic1.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  cmMsec2 = ultrasonic1.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  cmMsec3 = ultrasonic1.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  
  cmMsec = (cmMsec1 + cmMsec2 + cmMsec3) / 3;
  
  inMsec = ultrasonic1.convert(microsec, Ultrasonic::IN); //Calcula a distancia em polegadas
  cmCorpo = cmMsec;
  if (Imprime != 0)
  {
    Print("Cent: ");
    sprintf(sInfo,"%f",cmMsec);
    Print(String(sInfo));
    Print(", Pol. : ");
    sprintf(sInfo,"%f",inMsec);
    Println(String(sInfo));
  }
}

void Le_Ultrasom2(int Imprime)
{
  float cmMsec, inMsec;
  float cmMsec1, cmMsec2, cmMsec3;
  long microsec = ultrasonic2.timing();  //Le os dados do sensor, com o tempo de retorno do sinal

  cmMsec1 = ultrasonic2.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  cmMsec2 = ultrasonic2.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  cmMsec3 = ultrasonic2.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  
  cmMsec = (cmMsec1 + cmMsec2 + cmMsec3) / 3;
  
  inMsec = ultrasonic2.convert(microsec, Ultrasonic::IN); //Calcula a distancia em polegadas
  cmCorpo = cmMsec;
  if (Imprime != 0)
  {
    Print("Cent: ");
    sprintf(sInfo,"%f",cmMsec);
    Print(String(sInfo));
    Print(", Pol. : ");
    sprintf(sInfo,"%f",inMsec);
    Println(String(sInfo));
  }
}


void Le_GPS()
{
  // Read a byte of the serial port
  bool flgsair = false;
  while (!flgsair)
  {
    if (!Serial3.available()) {          // See if the port is empty yet
      //delay(100); //MMM
    }
    else {
      byteGPS = Serial3.read();
      // note: there is a potential buffer overflow here!
      linea[conta] = byteGPS;      // If there is serial port data, it is put in the buffer
      conta++;
      //Serial.print(byteGPS);
      if (byteGPS == 13) {         // If the received byte is = to 13, end of transmission
        // note: the actual end of transmission is <CR><LF> (i.e. 0x13 0x10)
        //digitalWrite(ledPin, LOW);
        cont = 0;
        bien = 0;
        // The following for loop starts at 1, because this code is clowny and the first byte is the <LF> (0x10) from the previous transmission.
        for (int i = 1; i < 7; i++) { // Verifies if the received command starts with $GPR
          if (linea[i] == comandoGPR[i - 1]) {
            bien++;
          }
        }
        if (bien == 6) {           // If yes, continue and process the data
          for (int i = 0; i < 300; i++) {
            if (linea[i] == ',') { // check for the position of the  "," separator
              // note: again, there is a potential buffer overflow here!
              indices[cont] = i;
              cont++;
            }
            if (linea[i] == '*') { // ... and the "*"
              indices[12] = i;
              cont++;
            }
          }
          Println("");      // ... and write to the serial port
          Println("");
          Println("---------------");
          for (int i = 0; i < 12; i++) {
            switch (i) {
              case 0 :
                Print("Time in UTC (HhMmSs): ");
                break;
              case 1 :
                Print("Status (A=OK,V=KO): ");
                break;
              case 2 :
                Print("Latitude: ");
                break;
              case 3 :
                Print("Direction (N/S): ");
                break;
              case 4 :
                Print("Longitude: ");
                break;
              case 5 :
                Print("Direction (E/W): ");
                break;
              case 6 :
                Print("Velocity in knots: ");
                break;
              case 7 :
                Print("Heading in degrees: ");
                break;
              case 8 :
                Print("Date UTC (DdMmAa): ");
                break;
              case 9 :
                Print("Magnetic degrees: ");
                break;
              case 10 :
                Print("(E/W): ");
                break;
              case 11 :
                Print("Mode: ");
                break;
              case 12 :
                Print("Checksum: ");
                break;

            }
            for (int j = indices[i]; j < (indices[i + 1] - 1); j++) {
              Print(String(linea[j + 1]));
            }
            Println("");
          }
          Println("---------------");
          flgsair = true;
        }
        conta = 0;                  // Reset the buffer
        for (int i = 0; i < 300; i++) { //
          linea[i] = ' ';
        }
      }
    }
  }

}

void EnviaArduino(String info)
{
  mySerial.println(info);
}

//Teste Movimento
void TesteMovimento()
{
  mySerial.println("TESTE");

  CLS();
  Imprime(0, "Teste de Mov 1");
  Imprime(1, "Gira Cabeca");
  delay(1000);
  Cabeca.write(0);
  delay(1000);
  Cabeca.write(180);
  delay(1000);
  Cabeca.write(90);
  delay(1000);
  Cabeca.write(180);
  delay(1000);
  Cabeca.write(0);
  delay(1000);
  Cabeca.write(90);
  delay(1000);
  CLS();
  Imprime(0, "Teste de Mov 2");
  Imprime(1, "Lev. Braco Dir");
  BDireito.write(170);
  delay(1500);
  CLS();
  Imprime(0, "Teste de Mov 3");
  Imprime(1, "Lev. Braco Dir");
  BDireito.write(90);
  delay(1500);
  CLS();
  Imprime(0, "Teste de Mov 4");
  Imprime(1, "Abaixa Braco Dir");
  BDireito.write(10);
  delay(1500);
  MDireita.write(155);
  CLS();
  Imprime(0, "Teste de Mov 5");
  Imprime(1, "Gira Mao Dir");
  MDireita.write(10);
  delay(1500);
  CLS();
  Imprime(0, "Teste de Mov 6");
  Imprime(1, "Gira Mao Esq");
  BEsquerdo.write(2);
  delay(1500);

  CLS();
  Imprime(0, "Teste de Mov 7");
  Imprime(1, "Abaix Braco Dir");
  BDireito.write(0);
  delay(1500);
  MDireita.write(155);
  CLS();
  Imprime(0, "Teste de Mov 8");
  Imprime(1, "Gira Mao Esq");
  BEsquerdo.write(90);
  //PEsquerdo.write(90);
  delay(1500);
  CLS();
  Imprime(0, "Teste de Mov 9");
  Imprime(1, "Abre GARRA Esq");
  GARRAESQ.write(150);
  delay(1500);
  CLS();
  Imprime(0, "Teste de Mov 10");
  Imprime(1, "Fecha GARRA Esq");
  GARRAESQ.write(7);
  delay(1500);
  
  CLS();
  Imprime(0, "Teste de Mov 11");
  Imprime(1, "Gira P Esq");
  PEsquerdo.write(0);
  delay(1500);
  CLS();
  Imprime(0, "Teste de Mov 12");
  Imprime(1, "Gira P Esq");
  PEsquerdo.write(90);
  delay(1500);
  PEsquerdo.write(180);
  delay(1500);
  PEsquerdo.write(90);
  delay(1500);

  //Cabeca.write(0);
  CLS();
  Imprime(0, "Teste de Mov 13");
  Imprime(1, "Gira Mao Dir");
  MDireita.write(90);
  delay(1500);
  MDireita.write(155);
  CLS();
  Imprime(0, "Teste de Mov 14");
  Imprime(1, "Gira Mao Dir");
  MDireita.write(0);
  delay(1500);

  MDireita.write(155);
  BEsquerdo.write(166);
  delay(1500);
  BEsquerdo.write(2);
  BDireito.write(10);
  delay(1500);
  BEsquerdo.write(166);
  BDireito.write(10);
  delay(1500);
  BEsquerdo.write(2);
  BDireito.write(180);
  delay(1500);
  BEsquerdo.write(166);
  BDireito.write(10);
  CLS();
  Imprime(0, "Teste de Mov ");
  Imprime(1, "Fim de Teste");
  //Cabeca.write(90);
}

void Le_Arduino()
{
  // if we get a valid byte, read analog ins:
  if (mySerial.available() > 0) {
    // get incoming byte:
    inByte = mySerial.read();
    if (inByte != '\n')
    {
      Buffer += inByte;
    }
    else
    {
      ExecCMD(Buffer);
      ImprimeCursor();
      Buffer = "";
    }
  }
}

void Le_Bluetooth()
{
   
  //BLUETOOTH
  if (Serial1.available() > 0) {
    // get incoming byte:
    inByte = Serial1.read();
    Serial.print(inByte);

    if (inByte != '\n')
    {
      Buffer += inByte;
    }
    else
    {
      ExecCMD(Buffer);
      ImprimeCursor();
      Buffer = "";
    }
  }
}

void Carrega_RC()
{
   if (mySwitch.available()) {
    
    int value = mySwitch.getReceivedValue();
    
    if (value == 0) {
      Serial.print("Unknown encoding");
    } else {
      Serial.print("Received ");
      Serial.print( mySwitch.getReceivedValue() );
      Serial.print(" / ");
      Serial.print( mySwitch.getReceivedBitlength() );
      Serial.print("bit ");
      Serial.print("Protocol: ");
      Serial.println( mySwitch.getReceivedProtocol() );
    }

    mySwitch.resetAvailable();
  }
}


void Carrega_Monitor()
{
  char Info[255];
  if (flgMonitor == true)
  {
    intMonitor++;
    if (intMonitor == 1)
    {
      CLS();
      Imprime(0, "Robotinics ");
      Imprime(1, "V." + String(FVersao));
    }

    if (intMonitor == 100)
    {
      CLS();
      Imprime(0, "Corrente");
      sprintf(sInfo,"%fA",Corrente);
      Imprime(1, String(sInfo));
    }
    if (intMonitor == 200)
    {
      CLS();
      Imprime(0, "Tensao");
      Imprime(1, "12V");
    }

    if (intMonitor == 300)
    {
      CLS();
      Imprime(0, "GAS");
      //sprintf(Info,"%G A",Corrente);
      if (thickness < -10812)
      {
         Imprime(1,"Nao identific");
      }
      if ((thickness > -10812) && (thickness < -3462))
      {
         Imprime(1,"Indicio");
      }

      if ((thickness > -3462) && (thickness < 1990))
      {
         Imprime(1,"Detectado");
      }

      if ((thickness > 1990))
      {
         Imprime(1,"Forte");
      }
    }
    if (intMonitor == 400)
    {
      CLS();
      Imprime(0, "Acelerometro");
      //sprintf(Info,"%G A",Corrente);
      Imprime(1, "X:" + String(xValue) + "Y:" + String(yValue) + "Z:" + String(zValue));
    }


    if (intMonitor == 500)
    {
      CLS();
      Imprime(0, "Status");
      if (Is_FRENTE())
      {
        Imprime(1, "Avanco");
      }
      if (Is_RE())
      {
        Imprime(1, "Re");
      }
      if ((Is_RE() == false) && (Is_FRENTE() == false))
      {
        Imprime(1, "Parado");
      }
    }
    if (intMonitor == 600)
    {
      CLS();
      Imprime(0, Msg01);
      //sprintf(Info,"%G A",Corrente);
      Imprime(1, Msg02);
    }


    if (intMonitor == 900)
    {
      intMonitor = 0;
    }

  }
}

void Le_Serial()
{
    // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();

    if (inByte != '\n')
    {
      Buffer += inByte;
    }
    else
    {
      ExecCMD(Buffer);
      ImprimeCursor();
      Buffer = "";
    }

  }
}

//Realiza Leituras de dispositivos
void Leituras()
{
  Le_Ultrasom(0);
  Le_Ultrasom1(0);
  Le_Arduino();
  Le_Bluetooth();
  Le_Serial();
  Carrega_gas();
  Carrega_corr();
  //Carrega_Monitor();
  Carrega_acel();
  Carrega_RC();
  //analisa margem de seguranca
  fMargem(true);
}

//Analisa e evita risco de colisão
void fMargem(bool flgView)
{
  if (Is_RE() == true)
  {
    if (cmRe < Margem)
    {
      if (flgView == true)
      {
        Print("Margem Seguranca RE ");
        Println(String(cmRe)+" cm");
      }
      Para();
    }
  }

  if (Is_FRENTE() == true)
  {
    if (cmCorpo < Margem)
    {
      if (flgView == true)
      {

        //sprintf(Info,"Margem segurança FRENTE: %d cm",cmCorpo)
        Print("Margem Seguranca da Frente ");
        Println(String(cmCorpo)+" cm");

      }
      Para();

    }
  }
}


void loop() {
 //Println(".");
  Leituras(); //realiza leituras de dispositivo
}


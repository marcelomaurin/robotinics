#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Ultrasonic.h>
#include <Servo.h>
#include <RCSwitch.h>

#if ARDUINO >= 100
#include <SoftwareSerial.h>
#else
#include <NewSoftSerial.h>
#endif

/*
  Robotinics - firmware Arduino Mega
  Refatoracao compativel com o protocolo legado v1.3.

  Objetivos desta versao:
  - manter pinagem, dispositivos, comandos e respostas existentes;
  - separar responsabilidades em abas .ino;
  - reduzir fragmentacao de RAM nas recepcoes seriais;
  - corrigir falhas inequívocas sem alterar o protocolo externo.
*/

char FVersao[10] = "1.3";

LiquidCrystal_I2C lcd(0x20, 16, 2);

Servo Cabeca;
Servo BDireito;
Servo MDireita;
Servo BEsquerdo;
Servo PEsquerdo;
Servo GARRAESQ;
Servo GarraDIR;

// Pinagem original
const uint8_t pinCabeca    = 6;
const uint8_t pinBDireito  = 44;
const uint8_t pinMDireita  = 8;
const uint8_t pinBEsquerdo = 9;
const uint8_t pinGARRAESQ  = 10;
const uint8_t pinGARRADIR  = 11;
const uint8_t pinPEsquerdo = 46;

const uint8_t pinVoltagem = A6;
const uint8_t pinacelx = A1;
const uint8_t pinacely = A2;
const uint8_t pinacelz = A3;
const uint8_t analogInGas = A4;
const uint8_t analogOutGas = A5;
const uint8_t analogInCorr = A0;

#define PINO_ENA  26
#define PINO_IN1  28
#define PINO_IN2  30
#define PINO_IN3  34
#define PINO_IN4  32
#define PINO_ENB  36

#define PINO_RFRX 17
#define PINO_RFTX 16
#define PINO_TRIGGER 2
#define PINO_ECHO 3
#define PINO_TRIGGER1 40
#define PINO_ECHO1 35
#define PINO_TRIGGER2 41
#define PINO_ECHO2 42
#define Arduino2TX 38
#define Arduino2RX 37

Ultrasonic ultrasonic(PINO_TRIGGER, PINO_ECHO);
Ultrasonic ultrasonic1(PINO_TRIGGER1, PINO_ECHO1);
Ultrasonic ultrasonic2(PINO_TRIGGER2, PINO_ECHO2);

#if ARDUINO >= 100
SoftwareSerial mySerial(Arduino2TX, Arduino2RX);
#else
NewSoftSerial mySerial(Arduino2TX, Arduino2RX);
#endif

RCSwitch mySwitch = RCSwitch();

// Estado compartilhado
int cmRe = 0;
int cmCorpo = 0;
int Margem = 20;

int xValue = 0, xLastValue = 0;
int yValue = 0, yLastValue = 0;
int zValue = 0, zLastValue = 0;
float xAcel = 0, yAcel = 0, zAcel = 0;

float Corrente = 0;
float thickness = 0;

bool flgMonitor = true;
int intMonitor = 0;

String Msg01;
String Msg02;
char sInfo[255];

void setup()
{
  StartSerial();
  StartArduino();
  StartBluetooth();
  Start_lcd();
  Start_GPS();

  CLS();
  Imprime(0, "Posicionando");
  Imprime(1, "corpo");

  Start_Cabeca();
  Start_BDireito();
  Start_MDireita();
  Start_BEsquerdo();
  Start_GARRAESQ();
  Start_PEsquerdo();

  StartMotor();
  Start_acel();
  StartGas();

  StartWelcomme();
}

void loop()
{
  Leituras();
}

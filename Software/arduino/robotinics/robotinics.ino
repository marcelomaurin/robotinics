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

#include "robotinics_config.h"

/*
  Robotinics - Body Controller / Arduino Mega
  Rev. 4 core, compativel com o protocolo legado v1.3.

  Este arquivo concentra apenas:
  - objetos compartilhados;
  - estado global indispensavel;
  - setup();
  - loop().

  As responsabilidades ficam separadas nas abas numeradas.
*/

char FVersao[10] = ROBOTINICS_FIRMWARE_VERSION;

LiquidCrystal_I2C lcd(0x20, 16, 2);

Servo Cabeca;
Servo BDireito;
Servo MDireita;
Servo BEsquerdo;
Servo PEsquerdo;
Servo GARRAESQ;
Servo GarraDIR;

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
int Margem = ROBOTINICS_COLLISION_MARGIN_CM;

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
  StartRC();
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

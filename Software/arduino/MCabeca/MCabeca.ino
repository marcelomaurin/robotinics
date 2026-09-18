/*
  ROBOTINICS - Modulo Cabeca
  Arduino Nano / ATmega328P

  Refatoracao compativel com o firmware 1.2.
  Mantem pinagem, baud rate e protocolo externo.
*/

#include <Servo.h>
#include <Ultrasonic.h>

const char FVersao[] = "1.2";

// Pinagem original do Arduino Nano
const uint8_t PINO_TRIGGER = 13;
const uint8_t PINO_ECHO = 2;
const uint8_t PIN_CABECA_X = 8;
const uint8_t PIN_CABECA_Y = 12;
const uint8_t PIN_LASER = 3;
const uint8_t PIN_OLHOS = 7;
const uint8_t PIN_LED_AZUL = 6;
const uint8_t PIN_LED_VERDE = 9;
const uint8_t PIN_LED_VERMELHO = 4;

const uint8_t CABECA_X_HOME = 90;
const uint8_t CABECA_Y_HOME = 0;

uint8_t currentX = CABECA_X_HOME;
uint8_t currentY = CABECA_Y_HOME;
bool lightAuto = true;

Ultrasonic ultrasonic(PINO_TRIGGER, PINO_ECHO);
Servo CabecaX;
Servo CabecaY;

int cmCabeca = 0;

// Buffer fixo: evita fragmentacao da SRAM de 2 KB do Nano.
const uint8_t RX_BUFFER_SIZE = 64;
char rxBuffer[RX_BUFFER_SIZE];
uint8_t rxPos = 0;

// Estado da animacao luminosa.
uint8_t contcor = 0;
unsigned long ultimoPassoLuz = 0;
const unsigned long INTERVALO_LUZ_MS = 200;

void setup()
{
  Start_Serial();
  Start_Servo();
  Start_Olhos();
  Start_Cores();
  Start_Laser();
  Prompt();
}

void loop()
{
  Leituras();
  VariaLuz();
}

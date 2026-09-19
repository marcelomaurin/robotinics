#ifndef ROBOTINICS_CONFIG_H
#define ROBOTINICS_CONFIG_H

#include <Arduino.h>

/*
  Robotinics Rev. 4 - configuracao do Body Controller (Arduino Mega)

  IMPORTANTE:
  - os valores abaixo preservam a pinagem do firmware legado v1.3;
  - alteracoes de pinagem exigem revisao da documentacao e validacao fisica;
  - baud rates fazem parte do contrato de compatibilidade.
*/

#define ROBOTINICS_FIRMWARE_VERSION "1.3"

// Interfaces
static const unsigned long ROBOTINICS_USB_BAUD = 115200;
static const unsigned long ROBOTINICS_BLUETOOTH_BAUD = 9600;
static const unsigned long ROBOTINICS_HEAD_BAUD = 9600;
static const unsigned long ROBOTINICS_GPS_BAUD = 4800;

// Servos / corpo
static const uint8_t pinCabeca    = 6;
static const uint8_t pinBDireito  = 44;
static const uint8_t pinMDireita  = 8;
static const uint8_t pinBEsquerdo = 9;
static const uint8_t pinGARRAESQ  = 10;
static const uint8_t pinGARRADIR  = 11;
static const uint8_t pinPEsquerdo = 46;

// Entradas analogicas
static const uint8_t pinVoltagem = A6;
static const uint8_t pinacelx = A1;
static const uint8_t pinacely = A2;
static const uint8_t pinacelz = A3;
static const uint8_t analogInGas = A4;
static const uint8_t analogOutGas = A5;
static const uint8_t analogInCorr = A0;

// Ponte H / tracao
static const uint8_t PINO_ENA = 26;
static const uint8_t PINO_IN1 = 28;
static const uint8_t PINO_IN2 = 30;
static const uint8_t PINO_IN3 = 34;
static const uint8_t PINO_IN4 = 32;
static const uint8_t PINO_ENB = 36;

// RF
static const uint8_t PINO_RFRX = 17;
static const uint8_t PINO_RFTX = 16;

// Ultrassom
static const uint8_t PINO_TRIGGER  = 2;
static const uint8_t PINO_ECHO     = 3;
static const uint8_t PINO_TRIGGER1 = 40;
static const uint8_t PINO_ECHO1    = 35;
static const uint8_t PINO_TRIGGER2 = 41;
static const uint8_t PINO_ECHO2    = 42;

// Comunicacao com controlador secundario / MCabeca.
// Nomes historicos preservados; a documentacao de pinout explica a semantica.
static const uint8_t Arduino2TX = 38;
static const uint8_t Arduino2RX = 37;

// Seguranca
static const int ROBOTINICS_COLLISION_MARGIN_CM = 20;

// Timeout deterministico de tracao.
// Qualquer comando FRENTE/RE/GESQ/GDIR precisa ser renovado antes deste prazo
// para manter o movimento continuo.
static const unsigned long ROBOTINICS_MOTION_TIMEOUT_MS = 30000UL;

// Watchdog de atividade do controlador externo enquanto ha tracao ativa.
// Protege contra perda do Raspberry, USB ou cliente Bluetooth.
static const unsigned long ROBOTINICS_CONTROL_WATCHDOG_MS = 3000UL;

// Permite desligar temporariamente os timeouts em bancada sem alterar o codigo.
static const bool ROBOTINICS_SAFETY_TIMEOUTS_ENABLED = true;

#endif

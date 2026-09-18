# Pinout dos Controladores do Robotinics

[Projeto](../../../README.md) · [Arduino Mega](ARDUINO_MEGA_ATMEGA2560.md) · [MCabeca / Nano](MCABECA_ATMEGA328P.md) · [Raspberry Pi](RASPBERRY_PI_GPIO.md)

Esta documentação descreve o pinout dos principais controladores usados no Robotinics.

## Controladores documentados

- **Arduino Mega 2560 / ATmega2560** — controlador físico principal.
- **Arduino Nano / ATmega328P** — controlador do módulo MCabeca.
- **Raspberry Pi 4/5** — computador de bordo, documentado pelo header GPIO de 40 pinos.

## Regra de leitura

Sempre diferencie pino físico da placa, nome lógico usado pelo Arduino, porta do microcontrolador, função elétrica nativa e função atribuída pelo Robotinics.

Exemplo: Arduino Mega D6 → ATmega2560 PH3 → PWM → Robotinics: servo de cabeça.

## Fonte de verdade

Para o uso no Robotinics, a fonte primária é o código atualmente presente em `master`.

A documentação deve ser revisada quando houver mudança de pinagem, controlador, barramento, servo, sensor, UART, I²C, SPI ou alimentação.

## Segurança elétrica

Esta documentação descreve sinal e associação lógica. Ela não substitui o esquema elétrico. Verifique tensão lógica, corrente máxima, alimentação separada de servos/motores, terra comum, conversão 3,3 V/5 V e proteção de cargas indutivas.
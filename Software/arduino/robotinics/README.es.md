# Firmware Principal — Arduino Mega

[Robotinics](../../../README_ES.md) · [Arduino](../README.es.md) · [Português](README.md) · [English](README.en.md)

Este directorio contiene el firmware principal ejecutado en **Arduino Mega**.

## Motivo de uso

Robotinics necesita muchas conexiones físicas simultáneas. Arduino Mega ofrece una gran cantidad de pines y varias interfaces seriales, facilitando motores, servos, sensores y periféricos.

## Funciones

Controla motores de tracción, servos, sensores ultrasónicos, acelerómetro, gas, corriente, GPS, LCD, Bluetooth, RF y comunicaciones seriales.

## Seguridad

Una lógica básica de margen detiene el movimiento cuando el sensor correspondiente detecta un obstáculo demasiado próximo.

## Protocolo

Los comandos de texto forman parte del contrato del dispositivo y deben mantenerse compatibles.

## MCabeca

La evolución propuesta permite enviar comandos con prefijo `MCAB:` para el Arduino Nano y retransmitir sus respuestas.

El PR #3 reorganiza el firmware en módulos internos sin reemplazar el hardware.

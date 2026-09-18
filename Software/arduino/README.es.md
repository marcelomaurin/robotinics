# Firmware Arduino de Robotinics

[Proyecto principal](../../README_ES.md) · [Software](../README.es.md) · [Português](README.md) · [English](README.en.md)

Este directorio contiene el firmware de los microcontroladores.

## Controladores

### Arduino Mega

Es el controlador físico principal. Se utiliza por la gran cantidad de pines disponibles para motores, servos, sensores y periféricos.

### Arduino Nano — MCabeca

Es el controlador especializado de la cabeza. Controla dos ejes, láser, LEDs, ojos y ultrasonido.

La calibración de cámara y el procesamiento visual se realizan en Raspberry Pi.

## Protocolo

Robotinics utiliza comandos de texto terminados por salto de línea. La compatibilidad con comandos existentes debe mantenerse.

## Reglas de desarrollo

Los cambios deben preservar pines, documentar nuevos comandos, evitar romper funciones existentes y respetar las limitaciones de memoria de cada microcontrolador.

PR #3 refactoriza el Mega y PR #4 optimiza MCabeca para Arduino Nano.

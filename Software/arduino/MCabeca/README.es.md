# MCabeca — Módulo de Percepción Activa

[Robotinics](../../../README_ES.md) · [Arduino](../README.es.md) · [Português](README.md) · [English](README.en.md)

**MCabeca** es un módulo especializado basado en **Arduino Nano / ATmega328P**.

## Hardware controlado

Controla dos servos, puntero láser, LEDs azul/verde/rojo, luces de los ojos y un sensor ultrasónico.

## Función del láser

El láser se utiliza como referencia óptica y puntero visual. No se utiliza como arma.

Combinado con una cámara, permite realizar experimentos de percepción activa.

## Cámara y calibración

La visión y la calibración se realizan en Raspberry Pi. El Nano sólo recibe ángulos X/Y y ejecuta el movimiento.

## Aplicaciones

- apuntado visual;
- scanning angular;
- detección del punto láser;
- ayuda a visión monocular;
- triangulación en Raspberry;
- perfil aproximado de objetos;
- fusión de distancia visual y ultrasónica.

## LEDs independientes

Los LEDs deben aceptar comandos individuales y el modo automático no debe sobrescribir una orden manual.

## Protocolo

Se mantienen comandos históricos como `ULTRA`, `VER`, `LASERON`, `LASEROFF`, `SCANNING`, `POINT` y `TESTE`.

La evolución añade respuestas estructuradas como `MCAB:POS:` y `MCAB:DIST:`.

El PR #4 optimiza el firmware respetando las limitaciones de memoria del Arduino Nano.

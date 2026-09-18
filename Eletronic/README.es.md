# Electrónica de Robotinics

[Proyecto principal](../README_ES.md) · [Português](README.md) · [English](README.en.md)

Este directorio contiene la capa electrónica de Robotinics. Conecta los controladores embebidos con motores, servos, sensores, LEDs, módulos auxiliares y circuitos de alimentación.

## Objetivo

La electrónica fue concebida para permitir que el robot sea modificable y reparable sin depender de una placa propietaria única. El repositorio contiene varias generaciones de archivos, útiles como referencia de fabricación y como registro histórico.

## Estructura

### `arduino/`

Notas de pines y conexiones.

### `eagle/`

Proyectos EAGLE, incluyendo:

- control de servomotores;
- placas de LEDs;
- cargador;
- distribución de 5 V.

### `pcb/`

Diseños PCB, espejos e imágenes de distintas revisiones.

### `pcb wizzard/`

Archivos históricos de PCB Wizard.

## Integración

Los pines deben coincidir con los firmwares:

- Arduino Mega: controlador físico principal;
- Arduino Nano / MCabeca: módulo de cabeza.

Todo cambio de pin debe reflejarse en hardware, firmware y documentación.

## Alimentación

Los motores y servos pueden requerir corrientes elevadas. Se recomienda dimensionar correctamente la fuente, utilizar masa común cuando corresponda, evitar alimentar múltiples servos desde el regulador del Arduino y verificar caída de tensión bajo carga.

## Estado del material

Existen archivos de diferentes generaciones. No todos representan una versión lista para producción.

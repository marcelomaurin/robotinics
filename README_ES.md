# Robotinics

[Português](README.md) · [English](README_EN.md) · [Español](README_ES.md)

![Robotinics](Mecanic/solidwork/robotinics.JPG)

Robotinics es una plataforma abierta de robótica, automatización y experimentación que integra **mecánica, electrónica, firmware embebido, computación y software**.

El objetivo es ofrecer una base evolutiva para estudio, prototipado y desarrollo.

## Arquitectura

```text
                      Raspberry Pi
                visión / software / lógica
                           │
                           ▼
                     Arduino Mega
                 control físico principal
                  /        │         \
             motores    sensores    servos
                           │
                           ▼
                    MCabeca / Nano
                ┌──────────┼──────────┐
              Servo X    Servo Y    Ultrasonido
                           │
                       Láser / LEDs
```

## Módulos

- [Electrónica](Eletronic/README.md)
- [Mecánica](Mecanic/README.md)
- [Software](Software/README.md)
- [Arduino](Software/arduino/README.md)
- [Controlador Mega](Software/arduino/robotinics/README.md)
- [MCabeca](Software/arduino/MCabeca/README.md)
- [Raspberry](Software/raspberry/README.md)
- [Base de datos](Software/database/README.md)
- [Sitio web](Software/site/README.md)
- [Documentación](docs/README.md)

## MCabeca y percepción activa

MCabeca combina dos servos, un **puntero láser**, LEDs y un sensor ultrasónico. El láser se usa como referencia óptica y puntero visual.

Combinado con una cámara en Raspberry Pi, puede apoyar escaneo angular, detección del punto láser, experimentos de profundidad monocular y fusión de sensores.

La calibración y la visión pertenecen al Raspberry Pi. El microcontrolador sólo ejecuta ángulos y comandos físicos.

## Modernización

El firmware está siendo refactorizado manteniendo hardware y protocolo:

- PR #3 — firmware del Arduino Mega;
- PR #4 — optimización de MCabeca para Arduino Nano.

## Autor

**Marcelo Maurin Martins**

- GitHub: [marcelomaurin](https://github.com/marcelomaurin)
- Sitio: [Maurinsoft](https://maurinsoft.com.br)

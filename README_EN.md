# Robotinics

[Português](README.md) · [English](README_EN.md) · [Español](README_ES.md)

![Robotinics](Mecanic/solidwork/robotinics.JPG)

Robotinics is an open robotics, automation and experimentation platform that integrates **mechanics, electronics, embedded firmware, edge computing and software** in a single project.

It is designed as an evolvable base rather than only a finished robot.

## Overview

The project includes mechanical parts, PCB designs, an Arduino Mega main controller, an Arduino Nano head module, sensors, servos, motors, a laser pointer, ultrasonic sensing, Raspberry Pi integration, database resources, a web interface and educational documentation.

## Architecture

```text
                      Raspberry Pi
                 vision / software / logic
                           │
                           ▼
                     Arduino Mega
                 main physical control
                  /        │         \
             motors     sensors     servos
                           │
                           ▼
                    MCabeca / Nano
                ┌──────────┼──────────┐
              Servo X    Servo Y    Ultrasonic
                           │
                       Laser / LEDs
```

## Modules

- [Electronics](Eletronic/README.md)
- [Mechanics](Mecanic/README.md)
- [Software](Software/README.md)
- [Arduino firmware](Software/arduino/README.md)
- [Mega controller](Software/arduino/robotinics/README.md)
- [MCabeca](Software/arduino/MCabeca/README.md)
- [Raspberry Pi](Software/raspberry/README.md)
- [Database](Software/database/README.md)
- [Web interface](Software/site/README.md)
- [Documentation](docs/README.md)

## MCabeca and active perception

MCabeca combines two servos with a **laser pointer**, LEDs and an ultrasonic sensor. The laser is an optical reference and visual pointer, not a weapon.

Together with a Raspberry Pi camera, the module can support angular scanning, laser-dot detection, monocular depth experiments, area scanning and sensor fusion.

Camera calibration and vision processing belong to the Raspberry Pi. The microcontroller only executes physical angles and commands.

## Firmware modernization

The project is being modernized while preserving the existing hardware and legacy protocol:

- PR #3 — Arduino Mega firmware refactor;
- PR #4 — MCabeca optimization for Arduino Nano.

## Repository structure

```text
robotinics/
├── Eletronic/
├── Mecanic/
├── Software/
│   ├── arduino/
│   ├── database/
│   ├── raspberry/
│   └── site/
└── docs/
```

## Author

**Marcelo Maurin Martins**

- GitHub: [marcelomaurin](https://github.com/marcelomaurin)
- Website: [Maurinsoft](https://maurinsoft.com.br)

Robotinics is an experimental and educational project. Use appropriate safety practices when working with motors, electrical power, batteries, lasers and moving parts.

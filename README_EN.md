# Robotinics

[Português](README.md) · [English](README_EN.md) · [Español](README_ES.md)

![Robotinics](Mecanic/solidwork/robotinics.JPG)

Robotinics is an open robotics, automation and experimentation platform designed to integrate **mechanics, electronics, embedded firmware, Raspberry Pi processing and application software** in one project.

The goal is not merely to provide a finished robot. Robotinics is intended as an evolvable technical platform that can be studied, modified, reproduced and extended.

## Project scope

Robotinics includes:

- mechanical CAD models and printable parts;
- electronic schematics and PCB files;
- Arduino Mega as the main low-level controller;
- Arduino Nano as the MCabeca head controller;
- motors, servos and sensors;
- laser pointer and ultrasonic sensing;
- Raspberry Pi integration;
- database resources;
- a historical web interface;
- educational and historical documentation.

## System architecture

```text
                       Raspberry Pi
              vision / integration / logic
                            │
                            ▼
                      Arduino Mega
                 main physical controller
                 /        │          \
             motors     sensors     servos
                            │
                            ▼
                     MCabeca / Nano
                ┌──────────┼──────────┐
              Servo X    Servo Y    Ultrasonic
                            │
                        Laser / LEDs
```

The Raspberry Pi is intended for high-level processing. Arduino Mega concentrates physical I/O and deterministic control. MCabeca is a specialized peripheral dedicated to the robot head.

## Main modules

| Module | Purpose |
|---|---|
| [Electronics](Eletronic/README.en.md) | schematics, PCBs and power distribution |
| [Mechanics](Mecanic/README.en.md) | CAD, assemblies and printable parts |
| [Software](Software/README.en.md) | embedded and high-level software |
| [Arduino](Software/arduino/README.en.md) | microcontroller firmware |
| [Mega firmware](Software/arduino/robotinics/README.en.md) | main physical controller |
| [MCabeca](Software/arduino/MCabeca/README.en.md) | active head module |
| [Raspberry Pi](Software/raspberry/README.en.md) | high-level processing |
| [Database](Software/database/README.en.md) | persistence layer |
| [Web interface](Software/site/README.en.md) | historical web application |
| [Documentation](docs/README.en.md) | manuals and technical material |

## Arduino Mega

The Mega is used because Robotinics requires a large number of simultaneous I/O connections. The project values physical practicality, maintainability and straightforward wiring.

The main firmware handles:

- traction motors;
- servos;
- ultrasonic sensors;
- analog sensors;
- GPS;
- LCD;
- Bluetooth;
- RF;
- serial communication;
- auxiliary controller communication.

## MCabeca

MCabeca is based on an Arduino Nano and controls:

- horizontal servo;
- vertical servo;
- laser pointer;
- independent LEDs;
- eye lights;
- ultrasonic sensor.

Its role is to execute physical commands. It does not perform camera calibration or computer vision.

## Active perception

One of the most distinctive Robotinics concepts is the use of a movable laser pointer together with a camera.

The Raspberry Pi can:

1. capture an image;
2. detect the laser dot;
3. use calibration data;
4. convert image coordinates to physical angles;
5. command MCabeca;
6. combine visual information with ultrasonic distance.

This allows experiments with:

- visual pointing;
- angular scanning;
- monocular-depth assistance;
- active sensing;
- approximate profile reconstruction;
- sensor fusion.

The laser is an optical/visual reference and pointer, not a weapon.

## Software responsibility model

High-level tasks belong to Raspberry Pi:

- computer vision;
- camera calibration;
- triangulation;
- mission logic;
- application integration;
- optional AI.

Low-level deterministic tasks belong to the microcontrollers:

- motor control;
- servo positioning;
- sensor reading;
- LED control;
- laser on/off;
- basic local safety.

## Repository structure

```text
robotinics/
├── Eletronic/
│   ├── arduino/
│   ├── eagle/
│   ├── pcb/
│   └── pcb wizzard/
├── Mecanic/
│   ├── solidwork/
│   └── stl/
├── Software/
│   ├── arduino/
│   │   ├── robotinics/
│   │   └── MCabeca/
│   ├── database/
│   ├── raspberry/
│   └── site/
└── docs/
```

## Firmware modernization

Two compatibility-oriented refactors are currently documented:

- PR #3 — Arduino Mega firmware refactor;
- PR #4 — Arduino Nano / MCabeca optimization.

The objective is to improve maintainability, memory usage and module separation without requiring a new robot or changing the existing device protocol unnecessarily.

## Documentation policy

Robotinics documentation follows a modular approach:

- the root README explains the whole platform;
- each major subsystem has its own README;
- language versions are kept in separate files;
- detailed implementation information stays close to the relevant module.

Primary languages:

- Portuguese;
- English;
- Spanish.

## Historical material

The repository intentionally keeps historical CAD, PCB, software and documentation files. They are useful for understanding the evolution of the project, but not every file should be assumed to be the current reference revision.

## Author

**Marcelo Maurin Martins**

- GitHub: [marcelomaurin](https://github.com/marcelomaurin)
- Website: [Maurinsoft](https://maurinsoft.com.br)

Robotinics is an experimental and educational platform. Use appropriate safety procedures when handling motors, electrical power, batteries, moving parts and laser pointers.

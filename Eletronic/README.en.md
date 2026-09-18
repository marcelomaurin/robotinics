# Robotinics Electronics

[Main project](../README_EN.md) · [Português](README.md) · [Español](README.es.md)

This directory contains the electronic layer of Robotinics. It connects the embedded controllers to motors, servos, sensors, LEDs, auxiliary modules and power circuitry.

## Purpose

The electronics were designed to keep the robot modifiable and repairable without depending on one proprietary board. The repository contains several generations of circuit files, serving both as fabrication references and as a historical record of the project.

## Structure

### `arduino/`

Pinout notes and controller connection references.

### `eagle/`

Autodesk EAGLE projects, including:

- servo controller board;
- LED board;
- charger circuit;
- 5 V distribution board.

### `pcb/`

PCB layouts, fabrication mirrors and images from multiple revisions.

### `pcb wizzard/`

Historical PCB Wizard files.

## Software integration

Electronic pin assignments must match the embedded firmware:

- Arduino Mega: main physical controller;
- Arduino Nano / MCabeca: specialized head module.

Any pinout change should be reflected in hardware, firmware and documentation at the same time.

## Power

Motors and servos can require substantially more current than Arduino regulators can safely provide. When reproducing the hardware:

- size the power supply correctly;
- use common ground where required;
- avoid powering multiple servos from the Arduino regulator;
- provide appropriate protection and distribution;
- verify voltage drop under simultaneous load.

## Repository status

This folder contains historical and current material. Not every file should be treated as production-ready.

The documentation effort should progressively identify the official reference schematic, PCB, BOM and pinout.

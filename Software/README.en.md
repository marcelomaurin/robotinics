# Robotinics Software

[Main project](../README_EN.md) · [Português](README.md) · [Español](README.es.md)

This directory contains the software layers of Robotinics.

## Architecture

```text
Raspberry Pi
  processing / integration / vision
                │
                ▼
          Arduino Mega
       main physical controller
          │           │
          │           └── MCabeca / Arduino Nano
          │
          ├── motors
          ├── servos
          └── sensors
```

## Modules

- [Arduino](arduino/README.md): embedded firmware;
- [Raspberry](raspberry/README.md): high-level processing and integration;
- [Database](database/README.md): project data structures;
- [Site](site/README.md): historical web interface.

## Design principle

Microcontrollers should remain deterministic and hardware-focused. Vision, camera calibration, triangulation, mission logic and AI belong to the Raspberry Pi or another high-level computer.

Protocol compatibility between devices is considered part of the Robotinics system contract.

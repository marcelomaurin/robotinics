# Raspberry Pi in Robotinics

[Main project](../../README_EN.md) · [Software](../README.en.md) · [Português](README.md) · [Español](README.es.md)

The Raspberry Pi is the high-level processing layer of Robotinics.

## Role

Arduino boards handle physical control. Raspberry Pi is responsible for tasks requiring more memory, operating-system services and computational libraries.

Recommended responsibilities include:

- computer vision;
- camera capture;
- camera calibration;
- laser-dot detection;
- triangulation;
- coordinated scanning;
- mission logic;
- sensor integration;
- database and service access;
- external interfaces;
- optional AI.

## MCabeca relationship

Camera-to-servo calibration belongs to Raspberry Pi. MCabeca should only receive physical X/Y angles and hardware commands.

## Mega relationship

Raspberry coordinates high-level behavior, while the Mega remains responsible for immediate physical control, basic safety and peripheral communication.

A future directory structure can separate vision, calibration, robot control, protocol, telemetry and services while preserving historical code.


## AI layer

The current Robotinics continuation defines a dedicated Raspberry Pi AI runtime based on TCHATGPT, RAG, controlled internet access, vision, voice and telemetry.

See [AI/README.en.md](AI/README.en.md) and [../../docs/ai/README.en.md](../../docs/ai/README.en.md).

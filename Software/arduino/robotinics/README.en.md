# Main Firmware — Arduino Mega

[Robotinics](../../../README_EN.md) · [Arduino](../README.en.md) · [Português](README.md) · [Español](README.es.md)

This directory contains the main Robotinics firmware running on an **Arduino Mega**.

## Why Arduino Mega?

Robotinics uses a large number of physical I/O connections. The Mega provides many digital and analog pins plus multiple serial interfaces, making it practical for a robot with many motors, servos and sensors.

## Responsibilities

The firmware controls:

- traction motors;
- arm, wrist, gripper and head servos;
- multiple ultrasonic sensors;
- analog accelerometer;
- gas sensing;
- current measurement;
- GPS;
- I²C LCD;
- Bluetooth;
- RF;
- USB and auxiliary serial communication.

## Motion safety

A basic safety-margin routine stops forward or reverse movement when the corresponding ultrasonic sensor reports an obstacle closer than the configured limit.

## Protocol

Communication is command-oriented and text based. Existing commands are treated as part of the device contract.

Examples include:

```text
FRENTE
RE
PARA
GESQ
GDIR
ULTRA
ULTRA1
ULTRA2
GPS
ACEL
CORR
GAS
VER
TESTE
```

## MCabeca integration

The proposed compatibility layer allows commands such as:

```text
MCAB:DIST
MCAB:POINT:90,45
MCAB:LASERON
MCAB:LEDAZUL=ON
```

The Mega forwards them to the Nano and relays responses outward.

## Refactor

PR #3 decomposes the historical monolithic firmware into display, motor, servo, sensor, GPS, safety, communication and test modules while preserving hardware and protocol behavior.

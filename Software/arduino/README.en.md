# Robotinics Arduino Firmware

[Main project](../../README_EN.md) · [Software](../README.en.md) · [Português](README.md) · [Español](README.es.md)

This directory contains Robotinics microcontroller firmware.

## Main controllers

### Arduino Mega

The Mega is the main physical controller. Robotinics uses many simultaneous I/O lines, so the Mega provides a practical pin-rich platform for motors, servos and sensors.

It handles traction motors, servos, ultrasonic sensing, analog sensors, GPS, LCD, Bluetooth, RF and serial communication.

### Arduino Nano — MCabeca

MCabeca is a specialized head controller. It handles two servo axes, the laser pointer, LEDs, eye lights and an ultrasonic sensor.

Camera calibration and image processing are intentionally kept on the Raspberry Pi.

## Responsibility split

Microcontrollers execute physical commands. Higher-level perception, calibration, mission logic and AI belong to the Raspberry Pi.

## Protocol

Robotinics historically uses newline-terminated textual commands. Backward compatibility is important because multiple software layers may depend on this device protocol.

## Development rules

When changing firmware:

1. preserve pinout unless hardware is revised too;
2. document every new command;
3. avoid breaking legacy commands;
4. use bounded buffers on RAM-constrained boards;
5. avoid unnecessary blocking operations;
6. keep basic actuator safety close to the hardware.

PR #3 refactors the Mega firmware and PR #4 optimizes MCabeca for the Arduino Nano.

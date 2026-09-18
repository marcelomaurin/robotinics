# Robotinics Web Interface

[Main project](../../README_EN.md) · [Software](../README.en.md) · [Português](README.md) · [Español](README.es.md)

This directory contains the historical Robotinics web interface.

Current structure includes `index.htm`, CSS, JavaScript and images.

The web layer should not directly drive motors. A safer architecture is:

```text
Web → API/service → Raspberry Pi → Arduino Mega → hardware
```

This enables validation, logging, authentication and cleaner separation of responsibilities.

A future interface can expose telemetry, camera data, servo positions, sensor distance, scanning progress, manual controls and task information.

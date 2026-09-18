# Interfaz Web de Robotinics

[Proyecto principal](../../README_ES.md) · [Software](../README.es.md) · [Português](README.md) · [English](README.en.md)

Este directorio contiene la interfaz web histórica.

La estructura incluye HTML, CSS, JavaScript e imágenes.

La interfaz no debería controlar motores directamente. La arquitectura recomendada es:

```text
Web → API/servicio → Raspberry Pi → Arduino Mega → hardware
```

Una futura versión puede mostrar telemetría, cámara, servos, sensores, scanning, logs y tareas.

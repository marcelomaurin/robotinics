# Software de Robotinics

[Proyecto principal](../README_ES.md) · [Português](README.md) · [English](README.en.md)

Este directorio contiene las diferentes capas de software.

## Arquitectura

```text
Raspberry Pi
  procesamiento / integración / visión
                │
                ▼
          Arduino Mega
       controlador físico principal
          │           │
          │           └── MCabeca / Arduino Nano
          │
          ├── motores
          ├── servos
          └── sensores
```

Los microcontroladores deben concentrarse en control físico y lectura de sensores. La visión, calibración, triangulación, lógica de misión e IA pertenecen al Raspberry Pi.

La compatibilidad del protocolo entre dispositivos debe preservarse siempre que sea posible.

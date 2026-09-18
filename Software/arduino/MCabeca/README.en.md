# MCabeca — Active Perception Module

[Robotinics](../../../README_EN.md) · [Arduino](../README.en.md) · [Português](README.md) · [Español](README.es.md)

**MCabeca** is a specialized Robotinics head module based on an **Arduino Nano / ATmega328P**.

## Controlled hardware

It directly controls:

- horizontal servo;
- vertical servo;
- laser pointer;
- blue, green and red LEDs;
- eye lights;
- ultrasonic distance sensor.

## Laser purpose

The laser is an **optical reference and visual pointer**, not a weapon.

Two servo axes allow the pointer to be moved to known angles. Combined with the Robotinics camera, this supports active-perception experiments.

## Camera relationship

Image processing does not run on the Nano.

```text
Camera
  │
  ▼
Raspberry Pi
  ├── calibration
  ├── laser-dot detection
  ├── computer vision
  ├── depth estimation
  └── scan planning
            │
            ▼
        X/Y angles
            │
            ▼
         MCabeca
```

The Raspberry Pi converts image coordinates into servo angles. MCabeca only executes those physical angles.

## Active perception uses

The module can support:

- visual pointing;
- horizontal and vertical scanning;
- laser-dot detection;
- monocular-depth experiments;
- Raspberry-side triangulation;
- approximate profile reconstruction;
- visual + ultrasonic sensor fusion.

## Independent LEDs

LEDs and eye lights should be independently controllable. A manual command can disable automatic light animation so the requested state is preserved.

## Distance sensing

The ultrasonic sensor provides an independent distance measurement, useful for proximity, safety and coarse validation of visual depth estimates.

## Protocol

Legacy commands remain valid, including `ULTRA`, `VER`, `LASERON`, `LASEROFF`, `SCANNING`, `POINT` and `TESTE`.

The modernization also defines structured responses such as:

```text
MCAB:POS:90,45
MCAB:DIST:42.50
MCAB:OK:LEDAZUL=ON
```

## Nano constraints

Because the ATmega328P has limited RAM, the firmware should use fixed buffers, flash-stored constant strings and simple parsing while leaving calibration and vision to the Raspberry Pi.

PR #4 performs this refactor while preserving physical pinout and legacy behavior.

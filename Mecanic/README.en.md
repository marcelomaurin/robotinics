# Robotinics Mechanics

[Main project](../README_EN.md) · [Português](README.md) · [Español](README.es.md)

The `Mecanic` directory contains the physical Robotinics structure: CAD models, assemblies and parts for 3D printing.

## Purpose

Mechanical design is part of the system architecture. Robotinics was built so software, electronics and physical structure can evolve together.

## Structure

### `solidwork/`

SolidWorks parts and assemblies, including body sections, bases, arms, head parts, laser support and Raspberry Pi support.

### `stl/`

Exported files for fabrication and 3D printing.

## Head module

The mechanical head supports two servo axes, the laser pointer and the ultrasonic sensor. It can work together with a camera handled by the Raspberry Pi.

The laser is an optical/visual reference used in active-perception and scanning experiments.

## Revisions

Several historical revisions coexist. Before printing, verify scale, mounting points, servo compatibility and the intended assembly revision.

A future reference release should provide a complete mechanical BOM, printing orientation, material recommendations and assembly sequence.

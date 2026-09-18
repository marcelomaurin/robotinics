# Imagen Yocto de Robotinics

[Português](README.md) · [English](README.en.md)

Esta carpeta define la imagen reproducible para Raspberry Pi usando Yocto Project 6.0 Wrynose LTS, meta-raspberrypi y la capa meta-robotinics.

La máquina predeterminada es raspberrypi4-64 y también existe un manifiesto para raspberrypi5.

Build:

    cd yocto
    ./scripts/build.sh rpi4

La imagen incluye red, SSH, Python, gateway serie, funciones opcionales de visión y voz, y la base para el runtime TCHATGPT ARM64.

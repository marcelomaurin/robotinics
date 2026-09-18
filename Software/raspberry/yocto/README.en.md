# Robotinics Yocto Image

[Português](README.md) · [Español](README.es.md)

This directory defines the reproducible Robotinics Raspberry Pi image using Yocto Project 6.0 Wrynose LTS, meta-raspberrypi and the custom meta-robotinics layer.

Default machine is raspberrypi4-64, with raspberrypi5 also supported by the manifests.

Build:

    cd yocto
    ./scripts/build.sh rpi4

The image includes networking, SSH, Python, serial gateway support, optional vision and speech features, and the filesystem/configuration foundation for the TCHATGPT ARM64 runtime.

The TCHATGPT source recipe is pinned for reproducibility but is not installed by default until ARM64 compilation is validated.

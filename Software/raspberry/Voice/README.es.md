# Robotinics Voice

[Português](README.md) · [English](README.en.md)

Este módulo reemplaza el backend histórico eSpeak por una aplicación Lazarus/Free Pascal que utiliza `TAIVoiceSynthesizer` de TCHATGPT.

Las entradas públicas siguen compatibles:

```bash
robotinics-speak "texto"
robotinics-read-file archivo.txt
```

La aplicación genera WAV mediante la API TTS y lo reproduce de forma síncrona con `aplay`.


## Build ARM64 con Yocto

Use:

```bash
cd Software/raspberry/yocto
./scripts/build-voice.sh rpi4
```

El proceso prepara FPC 3.2.2, genera el compilador cruzado aarch64 con el toolchain Yocto, compila la unidad de voz TCHATGPT en modo headless e instala el binario ARM64 en `/opt/robotinics/voice/`.

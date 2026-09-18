# Robotinics Voice

[Português](README.md) · [Español](README.es.md)

This module replaces the historical eSpeak backend with a Lazarus/Free Pascal console application using TCHATGPT's `TAIVoiceSynthesizer`.

Public inputs remain compatible:

```bash
robotinics-speak "text"
robotinics-read-file file.txt
```

The application uses the OpenAI TTS engine, generates WAV and plays it synchronously with `aplay`.


## ARM64 Yocto build

Use:

```bash
cd Software/raspberry/yocto
./scripts/build-voice.sh rpi4
```

The build bootstraps FPC 3.2.2, creates an aarch64 cross compiler with the Yocto toolchain, compiles the headless TCHATGPT voice unit and installs the resulting ARM64 binary under `/opt/robotinics/voice/`.

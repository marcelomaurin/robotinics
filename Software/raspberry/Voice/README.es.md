# Robotinics Voice

[Português](README.md) · [English](README.en.md)

Este módulo reemplaza el backend histórico eSpeak por una aplicación Lazarus/Free Pascal que utiliza `TAIVoiceSynthesizer` de TCHATGPT.

Las entradas públicas siguen compatibles:

```bash
robotinics-speak "texto"
robotinics-read-file archivo.txt
```

La aplicación genera WAV mediante la API TTS y lo reproduce de forma síncrona con `aplay`.

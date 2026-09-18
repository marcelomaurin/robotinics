# Robotinics Voice

[Português](README.md) · [Español](README.es.md)

This module replaces the historical eSpeak backend with a Lazarus/Free Pascal console application using TCHATGPT's `TAIVoiceSynthesizer`.

Public inputs remain compatible:

```bash
robotinics-speak "text"
robotinics-read-file file.txt
```

The application uses the OpenAI TTS engine, generates WAV and plays it synchronously with `aplay`.

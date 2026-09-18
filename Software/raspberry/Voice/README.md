# Robotinics Voice

[English](README.en.md) · [Español](README.es.md) · [Raspberry](../README.md)

Este módulo substitui a síntese histórica baseada em eSpeak por uma aplicação console Lazarus/Free Pascal usando a biblioteca **TCHATGPT**, componente `TAIVoiceSynthesizer`.

## Compatibilidade de entrada

As entradas públicas permanecem as mesmas:

```bash
robotinics-speak "texto para falar"
robotinics-read-file arquivo.txt
```

Os wrappers chamam internamente:

```bash
robotinics-voice --text "texto para falar"
robotinics-voice --file arquivo.txt
```

Assim aplicações antigas não precisam mudar.

## Backend

A aplicação configura:

```pascal
Synth.Engine := seOpenAI;
Synth.OpenAIModel := 'gpt-4o-mini-tts';
Synth.OpenAIVoice := 'alloy';
Synth.OpenAIOutputFormat := 'wav';
Synth.Language := 'pt-BR';
Synth.Say(Texto);
```

O áudio WAV retornado é reproduzido de forma síncrona pelo `aplay`.

## Variáveis de ambiente

```text
ROBOTINICS_TTS_TOKEN
ROBOTINICS_TTS_ENDPOINT
ROBOTINICS_TTS_MODEL
ROBOTINICS_TTS_VOICE
ROBOTINICS_TTS_LANGUAGE
ROBOTINICS_TTS_INSTRUCTIONS
ROBOTINICS_TTS_SPEED
ROBOTINICS_TTS_OUTPUT
ROBOTINICS_AUDIO_PLAYER
```

Se `ROBOTINICS_TTS_TOKEN` estiver vazio, a aplicação usa `ROBOTINICS_LLM_TOKEN`.

## Defaults

```text
endpoint=https://api.openai.com/v1/audio/speech
model=gpt-4o-mini-tts
voice=alloy
language=pt-BR
format=wav
speed=1.0
output=/tmp/robotinics-voice.wav
player=/usr/bin/aplay
```

## Compilação

O projeto requer que o pacote `openai_voice` do TCHATGPT esteja instalado no Lazarus.

```bash
lazbuild robotinics_voice.lpi
```

No Raspberry ARM64, validar primeiro a compilação do pacote TCHATGPT.

## Migração do eSpeak

O eSpeak não é mais backend da implementação atual.

A pasta histórica `Output/speak/espeak` permanece apenas como registro do projeto antigo e não deve ser instalada na imagem Yocto moderna.


## Build ARM64 via Yocto

A imagem do Raspberry possui um fluxo próprio de cross-compilação:

```bash
cd Software/raspberry/yocto
./scripts/build-voice.sh rpi4
```

O build:

1. instala um bootstrap FPC 3.2.2 local em `yocto/.tools/`;
2. clona a tag oficial `release_3_2_2` do Free Pascal;
3. usa os binutils e o sysroot do Yocto para montar `ppcrossa64`;
4. compila uma cópia headless de `TAIVoiceSynthesizer`;
5. gera `robotinics-voice` para ARM64;
6. instala o binário em `/opt/robotinics/voice/robotinics-voice`.

A interface de linha de comando continua idêntica para os demais módulos.

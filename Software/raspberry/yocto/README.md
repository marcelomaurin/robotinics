# Robotinics Yocto Image

[English](README.en.md) · [Español](README.es.md) · [Raspberry](../README.md) · [Projeto principal](../../../README.md)

Esta pasta monta a imagem Linux reproduzível do Raspberry Pi para o Robotinics.

## Base

- Yocto Project 6.0 Wrynose LTS
- Poky
- meta-openembedded
- meta-raspberrypi
- meta-robotinics
- systemd
- arquitetura 64-bit

Máquinas previstas:

- raspberrypi4-64 como padrão
- raspberrypi5 como alternativa

## Estrutura

    yocto/
    ├── kas/
    ├── scripts/
    └── meta-robotinics/
        ├── conf/
        ├── recipes-core/
        └── recipes-robotinics/

## Build rápido

Instale kas e execute:

    cd Software/raspberry/yocto
    ./scripts/build.sh rpi4

Para Raspberry Pi 5:

    ./scripts/build.sh rpi5

Validação de metadados:

    ./scripts/check-layer.sh

## Conteúdo da imagem

A imagem robotinics-image instala:

- SSH
- Ethernet/Wi-Fi via NetworkManager
- Python 3
- pyserial e requests
- ferramentas USB/I2C
- gateway serial Robotinics
- estrutura de configuração em /etc/robotinics
- estado persistente em /var/lib/robotinics
- base da camada de IA
- interface de voz TCHATGPT quando a feature speech está habilitada
- V4L2/OpenCV quando a feature vision está habilitada

## Gateway serial

O serviço robotinics-gateway.service abre a serial do Mega em 115200 bps por padrão e registra o último estado conhecido em:

    /var/lib/robotinics/gateway-state.json

A IA não recebe acesso direto à serial.

## Configuração

Arquivo principal:

    /etc/robotinics/robotinics.env

Variáveis importantes:

    ROBOTINICS_SERIAL_PORT=/dev/ttyACM0
    ROBOTINICS_SERIAL_BAUD=115200
    ROBOTINICS_LLM_URL=
    ROBOTINICS_LLM_MODEL=
    ROBOTINICS_LLM_TOKEN=
    ROBOTINICS_DOCS_PATH=/opt/robotinics/docs

Tokens reais não devem ser gravados no repositório.

## TCHATGPT

A receita robotinics-tchatgpt-src fixa o snapshot do TCHATGPT no commit:

    e593fb758801cecb087e55e3222fc513cc35fee2

Ela é propositalmente uma receita de desenvolvimento e não entra na imagem padrão. O objetivo é fornecer uma fonte reproduzível para o trabalho de cross-compilação ARM64.

A validação do runtime deve ocorrer em etapas:

1. Free Pascal no target ou SDK
2. openai_core
3. TCHATGPT console mínimo
4. serial/gateway
5. RAG
6. Agent
7. visão e voz
8. serviço Robotinics AI

Só depois o runtime deve ser habilitado por padrão.

## Scripts históricos

Os antigos srvMonitor2 e srvFala não são instalados na imagem porque possuem problemas de segurança e robustez já registrados na Rev. 3. A imagem reaproveita a funcionalidade necessária em serviços novos.

A implementação eSpeak foi retirada da imagem. A interface pública continua sendo:

    robotinics-speak "texto"
    robotinics-read-file arquivo.txt

## Features

Nos manifests kas:

    ROBOTINICS_FEATURES ?= "vision speech ai"

A feature `speech` volta a fazer parte da imagem padrão. O build executa `scripts/bootstrap-fpc.sh`, prepara o compilador host FPC 3.2.2 e a receita `robotinics-voice-bin` monta o cross compiler `ppcrossa64` usando os binutils do Yocto antes de compilar o aplicativo.

## Próxima etapa

- validar parsing completo com bitbake
- compilar a imagem em host Yocto suportado
- testar boot no Raspberry físico
- confirmar serial do Mega
- validar câmera
- validar áudio
- validar o cross-compile em host Yocto suportado e no hardware real
- integrar atualização OTA posteriormente


## Cross-compile da voz ARM64

A implementação atual não depende da IDE Lazarus dentro da imagem. O projeto continua Lazarus para desenvolvimento, mas o build Yocto usa Free Pascal em modo headless.

Fluxo:

```text
bootstrap FPC x86_64
        |
fonte FPC release_3_2_2
        |
binutils/sysroot Yocto
        |
ppcrossa64
        |
TAIVoiceSynthesizer headless
        |
robotinics-voice ARM64
        |
/opt/robotinics/voice/robotinics-voice
```

Para compilar somente a voz:

```bash
cd Software/raspberry/yocto
./scripts/build-voice.sh rpi4
```

O script usa o pacote oficial FPC 3.2.2 como bootstrap e clona a tag oficial `release_3_2_2` do repositório Free Pascal. As units `aibase.pas` e `aivoicesynthesizer.pas` são sincronizadas da biblioteca TCHATGPT; para o build headless é removida apenas a dependência visual `LResources` e o recurso de ícone.

A API `TAIVoiceSynthesizer` e o engine `seOpenAI` permanecem os mesmos.


## Runtime de IA

A imagem instala dois serviços locais:

```text
robotinics-gateway.service  -> http://127.0.0.1:8765
robotinics-ai-api.service   -> http://127.0.0.1:8766
```

Teste:

```bash
./scripts/smoke-runtime.sh
./scripts/smoke-runtime.sh "faça um resumo do estado do robô"
```

Build isolado da IA:

```bash
./scripts/build-ai.sh rpi4
```

A API da IA aceita:

```bash
curl -X POST http://127.0.0.1:8766/v1/ask \
  -H 'Content-Type: application/json' \
  -d '{"question":"qual o estado atual?"}'
```

Cada pergunta gera uma tarefa em `/var/lib/robotinics/tasks/`.

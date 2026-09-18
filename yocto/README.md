# Robotinics Yocto Image

[English](README.en.md) · [Español](README.es.md) · [Projeto](../README.md)

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

    cd yocto
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
- voz com eSpeak quando a feature speech está habilitada
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

Os scripts antigos de voz foram substituídos pelos comandos:

    robotinics-speak "texto"
    robotinics-read-file arquivo.txt

## Features

Nos manifests kas:

    ROBOTINICS_FEATURES ?= "vision speech"

Para uma imagem menor, remova vision ou speech.

## Próxima etapa

- validar parsing completo com bitbake
- compilar a imagem em host Yocto suportado
- testar boot no Raspberry físico
- confirmar serial do Mega
- validar câmera
- validar áudio
- criar receita de cross-compile do aplicativo TCHATGPT
- integrar atualização OTA posteriormente

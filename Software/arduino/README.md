# Firmware Arduino do Robotinics

[Projeto principal](../../README.md) · [Software](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório concentra os firmwares dos microcontroladores usados pelo Robotinics.

## Controladores principais

### [Arduino Mega — robotinics](robotinics/README.md)

É o controlador físico principal do robô.

O Mega foi adotado porque o Robotinics utiliza grande quantidade de entradas e saídas simultâneas. Em vez de concentrar conectividade sem fio no mesmo microcontrolador, o projeto privilegia disponibilidade de pinos, simplicidade de ligação e manutenção do hardware.

Entre suas responsabilidades estão:

- motores de tração;
- servomotores;
- sensores ultrassônicos;
- acelerômetro analógico;
- sensor de gás;
- corrente;
- GPS;
- LCD;
- Bluetooth;
- RF;
- comunicação serial;
- comunicação com módulos auxiliares.

### [Arduino Nano — MCabeca](MCabeca/README.md)

É um módulo especializado da cabeça robótica.

Controla:

- servo horizontal;
- servo vertical;
- apontador laser;
- LEDs de cor;
- LEDs dos olhos;
- sensor ultrassônico.

O módulo não realiza calibração visual. A calibração e o processamento da câmera pertencem ao Raspberry Pi.

## Separação de responsabilidades

O firmware deve permanecer voltado à execução física.

```text
alto nível
Raspberry Pi
    │
    ▼
comandos físicos
Arduino Mega
    │
    ▼
módulos e atuadores
MCabeca / motores / sensores
```

Essa divisão evita sobrecarregar microcontroladores pequenos com tarefas de visão ou processamento que são mais adequadas ao Raspberry Pi.

## Protocolo

O Robotinics utiliza historicamente comandos de texto terminados por quebra de linha.

Exemplos:

```text
FRENTE
RE
PARA
ULTRA
VER
POINT:90,45
LASERON
LASEROFF
```

A compatibilidade do protocolo é importante porque diferentes camadas de software podem depender desses comandos.

## Desenvolvimento

Ao alterar um firmware:

1. preserve a pinagem física, salvo quando a revisão de hardware também for atualizada;
2. documente qualquer novo comando;
3. evite quebrar comandos legados;
4. mantenha buffers limitados para microcontroladores com pouca RAM;
5. evite bloqueios prolongados em tarefas críticas;
6. mantenha lógica de segurança próxima aos atuadores quando apropriado.

## Modernização

Existem duas frentes atuais:

- PR #3 — refatoração do firmware do Arduino Mega;
- PR #4 — otimização do MCabeca para Arduino Nano.

A meta é melhorar manutenção sem exigir troca do hardware físico.

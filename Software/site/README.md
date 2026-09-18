# Interface Web do Robotinics

[Projeto principal](../../README.md) · [Software](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório contém a interface web histórica do Robotinics.

## Estrutura

O conteúdo atual inclui:

- `index.htm`;
- `css/`;
- `js/`;
- `img/`.

## Papel

A interface web representa uma das formas de interação com o Robotinics.

Ela pode ser usada para apresentar informações do robô e servir como ponto de integração com serviços executados no Raspberry Pi ou em um servidor.

## Arquitetura recomendada

A interface web não deve conversar diretamente com motores.

O fluxo ideal é:

```text
Web
 │
 ▼
API / serviço
 │
 ▼
Raspberry Pi
 │
 ▼
Arduino Mega
 │
 ▼
Hardware
```

Isso permite validação de comandos, autenticação, registro de eventos e desacoplamento da interface.

## Conteúdo histórico

O site presente no repositório pertence a uma geração anterior do projeto.

Ele deve ser preservado como referência, mas uma nova versão pode evoluir para uma interface responsiva e orientada por API.

## Possíveis recursos futuros

- estado do robô;
- posição dos servos;
- distância dos sensores;
- telemetria;
- câmera;
- comandos manuais;
- acompanhamento de scanning;
- logs;
- configuração;
- visualização de tarefas.

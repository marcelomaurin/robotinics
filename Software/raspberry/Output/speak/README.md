# Saída de Voz

[Raspberry Output](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório contém recursos históricos de síntese de voz do Robotinics.

## Estrutura

- `espeak/` — integração baseada em eSpeak.

## Objetivo

A voz permite ao robô apresentar informações sem depender exclusivamente de uma tela.

Possíveis usos incluem:

- mensagens de inicialização;
- alertas;
- confirmação de comandos;
- estado de sensores;
- resultado de tarefas;
- interação experimental com usuários.

A síntese de voz pertence à camada de alto nível e não deve bloquear rotinas críticas de controle físico.

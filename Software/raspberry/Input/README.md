# Raspberry Input

[Raspberry](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este módulo reúne código histórico relacionado a entrada e aquisição no Raspberry Pi.

## Responsabilidade

A camada de entrada deve concentrar aquisição de dados vindos de:

- câmera;
- portas seriais;
- sensores conectados ao Raspberry;
- serviços externos;
- comandos de usuário.

Ela não deve executar diretamente lógica de controle de motores.

## Evolução

Em uma arquitetura futura, este módulo pode ser dividido em adaptadores específicos como `camera`, `serial`, `network` e `sensors`.

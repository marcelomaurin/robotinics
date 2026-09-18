# Raspberry Output

[Raspberry](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este módulo reúne código histórico relacionado às saídas do Raspberry Pi.

## Responsabilidade

A camada de saída deve encapsular o envio de informações e comandos para:

- Arduino Mega;
- módulos auxiliares;
- interface de usuário;
- serviços externos;
- logs e telemetria.

## Princípio

A saída de alto nível deve ser convertida em comandos de protocolo bem definidos antes de chegar aos microcontroladores.

Isso evita que regras de aplicação fiquem misturadas com detalhes de serial ou hardware.

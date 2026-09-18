# Saída para Arduino

[Raspberry Output](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório reúne componentes históricos utilizados para comunicação ou monitoramento relacionado aos controladores Arduino.

## Conteúdo

Existem módulos como:

- `srvFala/`;
- `srvMonitor2/`.

Eles representam serviços e experimentos de integração desenvolvidos ao longo da evolução do Robotinics.

## Papel arquitetural

A comunicação com o Arduino deve ser encapsulada por uma camada própria.

```text
aplicação / visão
       │
       ▼
protocolo Robotinics
       │
       ▼
Arduino Mega
       │
       ▼
hardware
```

Isso permite que o restante do software trabalhe com ações de alto nível sem depender diretamente de detalhes da porta serial.

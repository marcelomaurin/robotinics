# Raspberry Pi no Robotinics

[Projeto principal](../../README.md) · [Software](../README.md) · [English](README.en.md) · [Español](README.es.md)

O Raspberry Pi representa a camada de processamento de alto nível do Robotinics.

## Função na arquitetura

Enquanto Arduino Mega e Arduino Nano executam controle físico, o Raspberry Pi é o local natural para tarefas que exigem mais memória, processamento, bibliotecas de sistema operacional e integração com serviços.

```text
Câmera / Rede / Aplicações
          │
          ▼
     Raspberry Pi
          │
          ▼
     Arduino Mega
          │
          ▼
     Hardware físico
```

## Estrutura atual

A pasta possui módulos históricos organizados em:

- `Input/` — entrada e aquisição;
- `Output/` — saída e integração.

Esses diretórios representam a evolução inicial do software Raspberry e devem ser entendidos como base histórica para uma arquitetura futura mais modular.

## Responsabilidades recomendadas

O Raspberry Pi deve concentrar:

- visão computacional;
- captura de câmera;
- calibração de câmera;
- detecção do ponto laser;
- triangulação;
- scanning coordenado;
- lógica de missão;
- integração de sensores;
- comunicação com banco e serviços;
- interface com aplicações externas;
- eventual uso de IA.

## Relação com o MCabeca

A calibração entre câmera, laser e servos pertence ao Raspberry Pi.

Fluxo:

```text
pixel detectado
    │
    ▼
modelo de calibração
    │
    ▼
ângulo X / Y
    │
    ▼
Mega / MCabeca
```

O MCabeca não deve carregar parâmetros de câmera ou cálculos ópticos.

## Relação com o Arduino Mega

O Raspberry pode atuar como coordenador e enviar comandos ao Mega.

O Mega deve continuar responsável por:

- controle físico imediato;
- leitura de sensores básicos;
- execução de servos;
- segurança local;
- comunicação com periféricos.

## Evolução sugerida

Uma futura organização pode separar:

```text
raspberry/
├── vision/
├── calibration/
├── robot/
├── protocol/
├── telemetry/
├── services/
└── tools/
```

Essa reorganização deve ser feita sem apagar o material histórico existente.

# Módulo de Câmera

[Raspberry](../../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório reúne recursos históricos de câmera e visão no Raspberry Pi.

## Estrutura

- `motion/` — recursos relacionados ao software Motion;
- `opencv/` — experimentos e recursos baseados em OpenCV.

## Papel no Robotinics

A câmera é um dos sensores de alto nível do projeto.

Ela pode ser usada para:

- captura do ambiente;
- detecção e rastreamento de objetos;
- detecção do ponto laser do MCabeca;
- calibração visual;
- scanning assistido;
- percepção monocular;
- registro de imagens e vídeo.

## MCabeca

A câmera e o MCabeca formam um par importante para percepção ativa.

O Raspberry deve realizar a calibração e transformar pixels em ângulos físicos, enquanto o Nano apenas posiciona os servos.

```text
camera → processamento → ângulo X/Y → MCabeca
```

O sensor ultrassônico pode complementar a análise visual com uma medida independente de distância.

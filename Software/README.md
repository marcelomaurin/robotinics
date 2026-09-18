# Software do Robotinics

[Projeto principal](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório reúne as diferentes camadas de software do Robotinics.

## Arquitetura

O software é distribuído entre controladores embarcados e sistemas de mais alto nível.

```text
Raspberry Pi
  processamento / integração / visão
                │
                ▼
          Arduino Mega
      controle físico principal
          │           │
          │           └── MCabeca / Arduino Nano
          │
          ├── motores
          ├── servos
          └── sensores
```

## Módulos

### [Arduino](arduino/README.md)

Firmwares dos microcontroladores.

Inclui:

- firmware principal do Arduino Mega;
- firmware MCabeca para Arduino Nano.

### [Raspberry](raspberry/README.md)

Software executado no Raspberry Pi.

A função dessa camada é coordenar recursos de mais alto nível, realizar integração e servir como ponto natural para visão computacional, calibração e lógica de aplicação.

### [Database](database/README.md)

Estruturas de banco de dados mantidas pelo projeto.

### [Site](site/README.md)

Interface web histórica usada para interação com o Robotinics.

## Filosofia de projeto

A camada de firmware deve permanecer simples e previsível.

Tarefas como:

- visão computacional;
- calibração da câmera;
- interpretação de imagem;
- triangulação;
- lógica de missão;
- inteligência artificial;

devem permanecer no Raspberry Pi ou em outro computador de alto nível.

Já tarefas como:

- acionar motor;
- posicionar servo;
- ler sensor;
- controlar LED;
- ligar/desligar laser;
- aplicar uma parada de segurança simples;

pertencem aos microcontroladores.

## Compatibilidade

O protocolo entre dispositivos faz parte do comportamento do Robotinics.

Refatorações internas devem, sempre que possível, manter compatibilidade com os comandos já utilizados.

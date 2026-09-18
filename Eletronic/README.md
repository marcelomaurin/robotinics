# Eletrônica do Robotinics

[Projeto principal](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório concentra a parte eletrônica do Robotinics. Ele representa a camada que conecta os controladores embarcados aos motores, servomotores, sensores, LEDs, módulos auxiliares e circuitos de alimentação.

## Objetivo

A proposta da eletrônica do Robotinics é permitir que o robô seja construído, modificado e reparado sem depender de uma única placa proprietária. O projeto reúne arquivos de diferentes períodos de evolução, servindo tanto como base de fabricação quanto como registro histórico das soluções adotadas.

## Estrutura

### `arduino/`

Contém anotações de pinagem e referências de conexão relacionadas aos microcontroladores.

O arquivo `pinos arduino.txt` registra parte da distribuição física usada no Arduino Mega, incluindo conexões de servos, motores, RF e LCD.

### `eagle/`

Contém projetos criados no Autodesk EAGLE.

Entre os circuitos existentes estão:

- placa controladora de servomotor;
- placa de LEDs;
- circuito do carregador;
- placa de distribuição de 5 V.

Esses arquivos devem ser tratados como projetos de hardware sujeitos a revisão. Antes de fabricar uma placa, confirme esquemático, alimentação, versão dos componentes e correspondência com o firmware utilizado.

### `pcb/`

Contém arquivos de placa, espelhos de fabricação e imagens de diferentes revisões.

Há materiais para:

- controle de servomotores;
- controle de LEDs;
- distribuição elétrica;
- fonte;
- versões intermediárias e históricas das placas.

### `pcb wizzard/`

Contém arquivos produzidos em versões anteriores do projeto usando PCB Wizard.

## Integração com o software

A eletrônica deve acompanhar a pinagem dos firmwares:

- Arduino Mega: controlador físico principal;
- Arduino Nano / MCabeca: módulo especializado da cabeça.

Alterações de pinagem devem ser refletidas simultaneamente no hardware, no firmware e na documentação.

## Alimentação

Motores e servos podem exigir correntes significativamente maiores do que as fornecidas diretamente pelos reguladores dos microcontroladores.

Ao reproduzir ou modificar o circuito:

- dimensione corretamente a fonte;
- mantenha terra comum entre os módulos quando necessário;
- evite alimentar vários servos diretamente pelo regulador do Arduino;
- utilize proteção e distribuição adequadas;
- verifique queda de tensão durante acionamentos simultâneos.

## Situação do conteúdo

O diretório contém material de diferentes gerações do Robotinics. Nem todo arquivo representa a revisão mais recente ou uma placa pronta para produção.

O objetivo da modernização da documentação é permitir identificar progressivamente:

1. arquivos históricos;
2. versão de referência;
3. esquemático atual;
4. PCB atual;
5. lista de materiais;
6. pinagem oficial.

## Segurança

Antes de energizar qualquer circuito, confirme polaridade, tensão nominal, corrente e isolamento. Motores, baterias e servos podem provocar aquecimento, curto-circuito ou movimento inesperado quando ligados incorretamente.

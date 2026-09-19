# Firmware Principal — Arduino Mega

[Robotinics](../../../README.md) · [Arduino](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório contém o firmware principal do Robotinics executado no **Arduino Mega**.

## Por que Arduino Mega?

O Robotinics possui grande número de conexões físicas simultâneas.

O Mega é adequado ao projeto por oferecer muitos pinos digitais e analógicos, várias interfaces seriais de hardware e uma plataforma simples de depurar e reparar.

A escolha privilegia praticidade de integração física em vez de concentrar tudo em um microcontrolador com menos I/O.

## Funções controladas

O firmware reúne controle e leitura de diferentes subsistemas:

### Tração

Controle dos dois lados da movimentação do robô por sinais de direção e habilitação.

Comandos históricos incluem:

```text
FRENTE
RE
PARA
GESQ
GDIR
```

### Servomotores

O firmware controla diferentes partes mecânicas, como braços, punhos, garra e cabeça.

Há comandos parametrizados para posicionamento.

### Sensores ultrassônicos

Existem sensores voltados a diferentes direções do robô.

Os comandos históricos incluem:

```text
ULTRA
ULTRA1
ULTRA2
```

Além da leitura manual, os sensores participam da lógica de margem de segurança.

### Sensores analógicos

O firmware possui suporte para:

- acelerômetro;
- sensor de gás;
- corrente;
- tensão ou referências relacionadas à alimentação.

### GPS

O GPS utiliza uma interface serial própria e trabalha com sentenças NMEA, em especial GPRMC.

### LCD

Um display LCD I²C é utilizado para informações locais de inicialização e estado.

### Comunicação

O firmware trabalha com diferentes canais:

- USB/Serial;
- Bluetooth;
- comunicação com Arduino secundário;
- GPS;
- rádio frequência.

## Segurança de movimento

O firmware possui uma lógica simples de distância mínima.

Quando o robô se move para frente ou para trás e o sensor correspondente indica obstáculo abaixo da margem configurada, o movimento é interrompido.

Essa lógica é deliberadamente mantida próxima ao controlador físico.

Na Rev. 4, a segurança de tração também inclui:

- `PARA` tratado com prioridade no parser;
- watchdog lógico de comunicação;
- heartbeat `PING` enviado pelo Gateway enquanto há movimento;
- parada automática se o controlador externo deixar de renovar o heartbeat;
- timeout máximo de uma ordem de movimento;
- motivo da parada exposto como `SAFETY:STOP:<reason>`;
- consulta local por `SAFETY`.

Configuração atual proposta para validação:

```text
heartbeat Gateway: 1 s
watchdog Mega:      3 s
timeout movimento: 30 s
```

Esses tempos são centralizados em `robotinics_config.h` e devem ser confirmados em ensaio físico antes de serem considerados parâmetros finais.

## Protocolo

A comunicação usa comandos de texto.

Essa interface deve ser tratada como parte do contrato do dispositivo, porque aplicações externas podem depender dela.

## MCabeca

O Mega também pode atuar como ponte de comunicação para o módulo MCabeca.

A evolução proposta utiliza um namespace:

```text
MCAB:<comando>
```

Exemplos:

```text
MCAB:DIST
MCAB:POINT:90,45
MCAB:LASERON
MCAB:LEDAZUL=ON
```

O Mega encaminha o conteúdo ao Nano e retorna as respostas ao canal externo.

## Refatoração

O firmware histórico concentrava todas as funcionalidades em um único arquivo.

A implementação da Rev. 4 separa internamente:

- display;
- motores;
- servos;
- sensores;
- GPS;
- segurança;
- comunicação;
- testes.

O objetivo é aumentar legibilidade, reduzir acoplamento e facilitar manutenção sem trocar hardware nem alterar o protocolo já usado pelo equipamento.

Estrutura atual:

```text
robotinics.ino          composição, estado compartilhado, setup e loop
robotinics_config.h     pinagem, baud rates e parâmetros físicos
10_display.ino          LCD e apresentação local
20_motors.ino           tração
30_servos.ino           servos do corpo
40_sensors.ino          sensores e leituras
50_gps.ino              GPS / NMEA
60_safety.ino           margem de colisão e ciclo de leituras
70_communications.ino   protocolo Device e canais seriais
80_tests.ino            teste funcional legado
```

Esta modularização ainda deve ser validada por compilação automatizada e ensaio no hardware real antes de ser considerada marco concluído.


## Pinout

O mapeamento entre pinos Arduino, portas do ATmega2560 e funções do Robotinics está documentado em [docs/hardware/pinout/ARDUINO_MEGA_ATMEGA2560.md](../../../docs/hardware/pinout/ARDUINO_MEGA_ATMEGA2560.md).

# Robotinics Rev. 4

A Rev. 4 organiza a evolução do Robotinics como uma plataforma robótica modular, testável e preparada para IA, sem descartar o hardware legado funcional.

> Status: **planejamento / implementação incremental**.
>
> Este documento não afirma que todos os itens descritos já estão implementados. O código atual continua sendo a principal fonte de verdade.

## Objetivo

Consolidar o Robotinics em três níveis claramente separados:

```text
Nível 2 — Cognitive Controller
Raspberry Pi
IA / RAG / visão / voz / planejamento / integração
                    |
                    | API local + Gateway
                    v
Nível 1 — Controllers
Arduino Mega                  Arduino Nano / MCabeca
Body Controller               Head Controller
                    |
                    v
Nível 0 — Hardware
motores / servos / sensores / drivers / alimentação
```

A IA nunca deve comandar PWM, GPIO, motores ou servos diretamente. Toda ação física deve atravessar uma camada determinística de validação.

## Princípios

1. preservar compatibilidade com o hardware existente;
2. preservar o protocolo Device legado durante a modernização;
3. separar cognição de controle físico;
4. manter funções críticas independentes de LLM;
5. tornar cada camada observável e testável;
6. permitir desenvolvimento sem o robô físico por meio de simulador;
7. tratar documentação e protocolo como parte do produto.

## Marcos

### M0 — Baseline Rev. 4
- arquitetura oficial;
- inventário de módulos;
- roadmap;
- critérios de compatibilidade;
- dívida técnica identificada.

### M1 — Core Firmware
- refatoração modular do Arduino Mega;
- refatoração do MCabeca;
- protocolo legado preservado;
- camada básica de segurança;
- documentação de pinagem sincronizada com o código.

### M2 — Robotinics Device Protocol
- catálogo formal de comandos;
- respostas e erros padronizados;
- versionamento;
- heartbeat;
- identificação de dispositivo;
- descoberta de capacidades sem quebra do protocolo legado.

### M3 — Gateway 2.0
- fila com prioridade;
- request id;
- timeout;
- retry controlado;
- estado unificado;
- histórico;
- eventos;
- diagnóstico;
- API local versionada.

### M4 — Simulator + CI
- simulador serial do Mega;
- simulador do MCabeca;
- cenários de falha;
- testes de protocolo;
- compilação automatizada de firmware;
- testes do Gateway e AI Runtime.

### M5 — Telemetria e Diagnóstico
- snapshot do estado do robô;
- autoteste;
- relatório de saúde;
- logs de falhas;
- modo de manutenção.

### M6 — Cognitive Runtime
- Task Engine com subtarefas;
- Agent Runtime;
- RAG híbrido;
- visão;
- voz;
- ferramentas controladas;
- confirmação para ações físicas.

### M7 — Control Center
- nova interface web;
- telemetria;
- câmera;
- tarefas;
- logs;
- diagnóstico;
- configuração.

### M8 — Robotinics OS
- imagem Yocto consolidada;
- serviços systemd;
- atualização;
- watchdog;
- configuração persistente;
- pacote reproduzível para Raspberry Pi.

## Compatibilidade

A Rev. 4 deve preservar, salvo alteração explicitamente documentada e revisada:

- pinagem física;
- baud rates;
- nomes dos comandos existentes;
- comportamento esperado dos comandos Device;
- limites mecânicos conhecidos;
- papel do Arduino Mega como controlador físico principal;
- papel do MCabeca como controlador especializado da cabeça.

## Critério de pronto

Um marco só deve ser considerado concluído quando houver:

- código correspondente;
- documentação sincronizada;
- teste reproduzível;
- procedimento de validação em hardware quando aplicável;
- registro das incompatibilidades introduzidas, se houver.

## Documentos

- [Arquitetura](ARCHITECTURE.md)
- [Roadmap executável](ROADMAP.md)
- [Compatibilidade e protocolo](PROTOCOL_COMPATIBILITY.md)

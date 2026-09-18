# Arquitetura de IA do Robotinics

## Princípio

A IA é uma camada cognitiva, não uma camada elétrica. Ela pode interpretar intenção, buscar informação, montar planos e explicar resultados. O firmware continua responsável pelo comportamento determinístico.

## Camadas

### 1. Hardware

Motores, sensores, servos, laser, LEDs e alimentação.

### 2. Controle determinístico

Arduino Mega e MCabeca.

Responsabilidades:

- comandos físicos;
- limites;
- timeouts;
- estados;
- intertravamentos;
- leituras.

### 3. Robot Gateway

Executado no Raspberry.

Responsável por:

- serial;
- catálogo de comandos;
- normalização de telemetria;
- timeout;
- heartbeat;
- request_id;
- log de execução.

### 4. Serviços

- câmera;
- voz;
- RAG;
- internet;
- banco;
- arquivos;
- telemetria.

### 5. TCHATGPT

- LLM;
- agente;
- planejamento;
- seleção de ferramenta;
- explicação;
- contexto.

## Internet como ferramenta

A internet é uma ferramenta do agente, equivalente a câmera ou RAG.

O LLM não recebe acesso irrestrito ao sistema operacional.

A ferramenta de internet recebe uma solicitação estruturada e retorna fontes, data de consulta, título e resumo.

## Estado central

O Raspberry deve manter um `RobotState` independente da conversa:

```text
connection
mode
armed
battery
motors
servos
distances
head_position
laser
leds
last_telemetry
faults
current_task
```

## Tarefas

Toda pergunta pode gerar uma tarefa lógica:

```text
Task
├── understand
├── collect_context
├── collect_telemetry
├── search_rag
├── search_internet
├── reason
└── answer
```

Ações físicas acrescentam:

```text
├── build_action_plan
├── validate
├── request_confirmation
├── execute
└── verify_telemetry
```

## Segurança

O validador deve rejeitar:

- comando não catalogado;
- parâmetro fora de faixa;
- movimento em estado não armado;
- telemetria antiga;
- ação baseada apenas em conteúdo web;
- cadeia ilimitada de ações;
- repetição automática após falha;
- ação física baseada apenas em memória de conversa.

## Operação sem internet

O robô deve continuar controlável sem internet e sem LLM.

Sem internet:

- RAG local continua disponível;
- telemetria continua disponível;
- controle manual continua disponível;
- segurança continua funcionando.

Sem LLM:

- gateway e firmware continuam operacionais.

# Robotinics AI Runtime — Raspberry Pi

[Documentação de IA](../../../docs/ai/README.md) · [English](README.en.md) · [Español](README.es.md)

Este módulo contém a implementação inicial da camada de IA do Robotinics no Raspberry Pi.

## Papel

O Raspberry funciona como computador de bordo e gateway entre:

- usuário;
- internet;
- TCHATGPT;
- câmera;
- voz;
- RAG;
- banco;
- Arduino Mega.

## Stack proposta

- Raspberry Pi OS 64-bit;
- Lazarus / Free Pascal;
- TCHATGPT;
- `openai_core`;
- `openai_agent`;
- `openai_rag`;
- `openai_project`;
- `openai_input`;
- `openai_vision`;
- `openai_voice`;
- serial para o Mega.

ARM64 deve ser validado componente a componente, conforme já orientado na Rev. 3.

## Componentes implementados

```text
robotinics-ai
├── TCHATGPT
├── GatewayClient
├── InternetService
├── DocumentationLookup
└── TaskEngine

robotinics-gateway
├── serial Mega
├── fila de comandos
├── request_id
├── timeout
├── parser de estado
├── catálogo de comandos
└── API HTTP local

robotinics-ai-api
└── API HTTP local para perguntas
```

Endpoints locais:

```text
Gateway: http://127.0.0.1:8765
AI:      http://127.0.0.1:8766
```

## LLMService

Usa `TCHATGPT`.

Pode trabalhar com provedores remotos ou endpoints OpenAI-compatible, inclusive servidores locais.

O provedor é configuração, não parte da lógica do robô.

## InternetService

Interface lógica:

```text
Search(query)
Fetch(url)
Extract(content)
Cite(source)
Cache(source)
```

O resultado entra no agente como contexto, nunca como comando físico.

## RAGService

Indexa:

- READMEs;
- Rev. 3;
- protocolo;
- manuais;
- documentação de hardware;
- notas de manutenção.

## RobotGateway

É o único serviço autorizado a conversar com o Mega.

Responsabilidades:

- serial;
- timeout;
- request_id;
- catálogo;
- telemetria;
- heartbeat;
- validação de estado.

O `TAIAgent` não recebe a porta serial diretamente.

## Exemplo conceitual

```pascal
Chat.Provider := AIP_OPENAI_COMPATIBLE;
Chat.URL := GetEnvironmentVariable('ROBOTINICS_LLM_URL');
Chat.Token := GetEnvironmentVariable('ROBOTINICS_LLM_TOKEN');
Chat.CustomModel := GetEnvironmentVariable('ROBOTINICS_LLM_MODEL');
Chat.Temperature := 0.2;

RAG.ChatGPT := Chat;
Agent.RAG := RAG;

// Ferramentas do agente:
// robot_state
// robot_sensor
// internet_search
// internet_fetch
// camera_observe
// documentation_lookup
// propose_robot_action
```

`propose_robot_action` produz proposta; não escreve na serial.

## Pipeline

```text
user
 |
 v
TAIAgent
 |
 +-- RAG
 +-- internet
 +-- vision
 +-- telemetry
 |
 v
structured answer
 |
 +-- informational -> response
 |
 +-- action -> validator -> confirmation -> RobotGateway
```

## Configuração

Variáveis sugeridas:

```text
ROBOTINICS_LLM_PROVIDER
ROBOTINICS_LLM_URL
ROBOTINICS_LLM_MODEL
ROBOTINICS_LLM_TOKEN
ROBOTINICS_SEARCH_URL
ROBOTINICS_SEARCH_TOKEN
ROBOTINICS_DOCS_PATH
ROBOTINICS_SERIAL_PORT
ROBOTINICS_SERIAL_BAUD
```

## Estado atual

Implementado nesta etapa:

1. RobotGateway com leitura e escrita serial;
2. fila de comandos e `request_id`;
3. validação de comandos;
4. estado persistido em JSON;
5. API HTTP local do gateway;
6. aplicação `robotinics-ai` em Lazarus/TCHATGPT;
7. criação de tarefa para cada pergunta;
8. coleta de telemetria e histórico;
9. busca de documentação local;
10. adaptador genérico de internet;
11. API local da IA;
12. recipes Yocto ARM64.

Ainda dependem de validação em hardware: build completo ARM64, câmera, STT e telemetria real do Mega.

## Documentação automática

`DocumentationService` pode usar as regras de `docs/ai/DOCUMENTATION_AGENT.md` para comparar código e documentação e gerar patches.

Por padrão, não faz push automático para `master`.

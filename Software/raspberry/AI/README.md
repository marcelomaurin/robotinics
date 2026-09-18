# Robotinics AI Runtime — Raspberry Pi

[Documentação de IA](../../../docs/ai/README.md) · [English](README.en.md) · [Español](README.es.md)

Este módulo documenta a implementação proposta da camada de IA do Robotinics no Raspberry Pi.

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

## Serviços

```text
RobotinicsAI
├── LLMService
├── AgentService
├── InternetService
├── RAGService
├── VisionService
├── VoiceService
├── TelemetryService
├── RobotGateway
├── DocumentationService
└── AuditService
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

## Roteiro de implementação

1. compilar `openai_core` no Raspberry;
2. testar `TCHATGPT` em console;
3. validar serial sem IA;
4. implementar `RobotGateway`;
5. indexar documentação com RAG;
6. implementar `InternetService`;
7. adicionar agente em modo somente leitura;
8. adicionar visão;
9. adicionar voz;
10. habilitar propostas de ação;
11. validar confirmação e telemetria;
12. criar testes de regressão.

## Documentação automática

`DocumentationService` pode usar as regras de `docs/ai/DOCUMENTATION_AGENT.md` para comparar código e documentação e gerar patches.

Por padrão, não faz push automático para `master`.

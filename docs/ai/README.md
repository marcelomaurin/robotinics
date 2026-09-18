# Robotinics AI — Continuação da Rev. 3

[English](README.en.md) · [Español](README.es.md) · [Projeto](../../README.md)

Esta pasta documenta a continuação do Robotinics com uma camada de inteligência executada no Raspberry Pi e baseada na biblioteca **TCHATGPT**.

## Objetivo

Transformar o Raspberry Pi em um computador de bordo capaz de:

- entender perguntas;
- consultar documentação local;
- consultar a internet quando necessário;
- interpretar telemetria;
- usar visão e voz;
- planejar tarefas;
- explicar o estado do robô;
- propor ações;
- manter documentação técnica atualizada.

Sem permitir que um LLM controle diretamente motores ou atuadores.

## Arquitetura

```text
                 INTERNET
                    |
             Internet Adapter
                    |
                    v
              Raspberry Pi
      +-------------+--------------+
      |             |              |
   TCHATGPT       TAIRAG         Vision
      |             |              |
      +------+------+-+------+------+
             |             |
          TAIAgent      Telemetry
             |
        Policy/Validator
             |
             v
        Robot Gateway
             |
             v
         Arduino Mega
             |
        MCabeca / Nano
```

## Componentes TCHATGPT sugeridos

- `TCHATGPT`: acesso ao LLM;
- `TAIAgent`: raciocínio e uso de ferramentas;
- `TAIRAG`: documentos locais;
- `TAIProject`: tarefas e organização;
- `TAIChromiumBrowser`: navegação/captura web quando aplicável;
- `TAIWebAPIServer`: exposição controlada de serviços;
- componentes seriais da suíte;
- componentes de visão;
- componentes de voz;
- observabilidade e TraceID quando disponíveis.

## Três fontes de conhecimento

### Estado físico

Vem da telemetria atual. Nunca deve ser inferido da conversa.

### Conhecimento do projeto

Vem do RAG indexando READMEs, Rev. 3, protocolo e documentação técnica.

### Conhecimento externo

Vem da integração com internet. Conteúdo externo nunca autoriza ação física.

## Fluxo de uma pergunta

```text
Pergunta
   |
   v
Planner
   |
   +-- precisa de RAG?
   +-- precisa da internet?
   +-- precisa da câmera?
   +-- precisa de telemetria?
   |
   v
Coleta de evidências
   |
   v
TCHATGPT
   |
   v
Resposta + fontes
```

Quando existe ação física:

```text
Resposta do LLM
     |
     v
Plano estruturado
     |
     v
Validador
     |
     v
Catálogo do dispositivo
     |
     v
Comando curto
     |
     v
Mega
```

## Documentação viva

A IA também pode atuar como mantenedora documental. Consulte `DOCUMENTATION_AGENT.md`.

## Documentos

- [Arquitetura](ARCHITECTURE.md)
- [Integração com Internet](INTERNET_INTEGRATION.md)
- [Agente de documentação](DOCUMENTATION_AGENT.md)
- [Implementação Raspberry](../../Software/raspberry/AI/README.md)

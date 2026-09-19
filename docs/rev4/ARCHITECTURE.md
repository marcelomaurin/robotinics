# Arquitetura Robotinics Rev. 4

## Visão geral

A Rev. 4 formaliza a separação entre hardware, controle determinístico e processamento de alto nível.

```text
Usuário / Control Center / serviços
              |
              v
       Robotinics AI Runtime
      tarefas / RAG / visão / voz
              |
              v
       Robotinics Gateway
   validação / fila / estado / API
              |
              v
         Arduino Mega
        Body Controller
       /      |       \
 motores   sensores   servos
              |
              +-------------------+
                                  |
                                  v
                         Arduino Nano
                         Head Controller
                      pan / tilt / laser
                       LEDs / ultrassom
```

## Nível 0 — Hardware

Inclui atuadores, sensores, drivers, alimentação, estrutura mecânica, placas e cabeamento.

Responsabilidades:
- executar o efeito físico;
- oferecer sinais elétricos aos controladores;
- respeitar limites mecânicos e elétricos definidos pelo projeto.

## Nível 1 — Controle determinístico

### Body Controller — Arduino Mega

Responsabilidades:
- motores de locomoção;
- servos do corpo;
- sensores diretamente conectados;
- comandos Device;
- intertravamentos simples;
- parada segura;
- comunicação com o computador de bordo;
- encaminhamento de comandos para módulos subordinados quando necessário.

Não é responsabilidade do Mega:
- interpretação de linguagem natural;
- acesso à internet;
- planejamento por LLM;
- visão computacional de alto nível.

### Head Controller — Arduino Nano / MCabeca

Responsabilidades:
- pan/tilt;
- laser apontador;
- LEDs;
- olhos;
- ultrassom;
- varreduras físicas locais.

O Raspberry é responsável por calibração visual e interpretação de imagem.

## Nível 2 — Cognitive Controller — Raspberry Pi

### Gateway

Único serviço autorizado a conversar diretamente com o Body Controller pela serial principal.

Responsabilidades:
- abrir e manter a conexão;
- serializar comandos;
- aplicar catálogo/validação;
- timeout;
- request id;
- parser de respostas;
- estado atual;
- histórico;
- eventos;
- health check.

### AI Runtime

Responsabilidades:
- receber perguntas;
- criar tarefas;
- consultar telemetria;
- consultar documentação;
- RAG;
- visão;
- voz;
- internet controlada;
- produzir diagnóstico e propostas de ação.

A saída do LLM não é autorização para hardware.

## Fluxo de ação física

```text
pedido do usuário
      |
      v
interpretação
      |
      v
plano / proposta
      |
      v
política e validação
      |
      v
confirmação quando necessária
      |
      v
Gateway
      |
      v
Body/Head Controller
      |
      v
hardware
      |
      v
telemetria observada
```

## Estado e telemetria

O estado deve distinguir:

- estado solicitado;
- estado confirmado pelo controlador;
- telemetria observada;
- inferência da IA.

Nunca tratar intenção de comando como comprovação de execução.

## Segurança

A segurança física deve existir abaixo da camada de IA.

Requisitos de arquitetura:
- parada prioritária;
- timeout de movimento;
- watchdog;
- limites de servo;
- rejeição de comandos desconhecidos;
- modo degradado quando o Raspberry falhar;
- ausência de execução direta de conteúdo vindo da internet.

## Interfaces futuras

A arquitetura deve permitir, sem obrigar a substituição do hardware atual:

- outros controladores;
- novos módulos de sensores;
- câmeras;
- microfones;
- alto-falantes;
- novos transportes além da serial;
- clientes web, desktop ou mobile.

A descoberta de capacidades deve reduzir dependência de configuração rígida, mas sem remover suporte ao protocolo legado.

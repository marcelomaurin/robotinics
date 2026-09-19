# Roadmap executável — Robotinics Rev. 4

Este roadmap transforma a proposta da Rev. 4 em entregas verificáveis.

## Fase 1 — Baseline e dívida técnica

### Entregáveis
- [x] arquitetura alvo documentada;
- [x] roadmap documentado;
- [x] regras de compatibilidade documentadas;
- [ ] inventário automático de código e hardware;
- [ ] mapa comando -> função -> hardware;
- [ ] lista de dependências Arduino;
- [ ] matriz de funcionalidades atual/proposta/histórica.

### Critério de conclusão
É possível identificar, a partir da documentação, onde cada responsabilidade reside e quais interfaces não podem ser quebradas.

---

## Fase 2 — Firmware Mega

### Atividades
- [ ] extrair pinagem para arquivo dedicado;
- [ ] separar motores;
- [ ] separar servos;
- [ ] separar sensores;
- [ ] separar display;
- [ ] separar GPS/RF/comunicações auxiliares;
- [ ] extrair parser de comandos;
- [ ] reduzir uso de `String`;
- [ ] eliminar código morto;
- [ ] corrigir bugs sem alterar protocolo;
- [ ] criar camada de telemetria;
- [ ] criar SafetyController.

### Compatibilidade obrigatória
Os comandos legados devem continuar aceitos durante esta fase.

### Critério de conclusão
O firmware compila para Mega, executa o protocolo atual e cada subsistema pode ser mantido isoladamente.

---

## Fase 3 — MCabeca

### Atividades
- [ ] separar pan/tilt;
- [ ] separar ultrassom;
- [ ] separar laser;
- [ ] separar LEDs/olhos;
- [ ] documentar limites;
- [ ] padronizar respostas;
- [ ] criar health/status;
- [ ] adicionar testes básicos.

### Critério de conclusão
O Head Controller possui API física previsível e não depende de lógica cognitiva.

---

## Fase 4 — Robotinics Device Protocol

### Atividades
- [ ] catalogar comandos atuais;
- [ ] catalogar formatos de resposta;
- [ ] definir `OK`, `ERR` e eventos;
- [ ] definir versionamento;
- [ ] definir heartbeat;
- [ ] definir `IDENTIFY`;
- [ ] definir `CAPABILITIES`;
- [ ] definir política de compatibilidade;
- [ ] definir depreciação futura.

### Critério de conclusão
Um software pode implementar um cliente Robotinics sem ler o firmware.

---

## Fase 5 — Safety Layer

### Atividades
- [ ] STOP prioritário;
- [ ] watchdog;
- [ ] timeout para movimento contínuo;
- [ ] estado seguro na perda de comunicação;
- [ ] limites dos servos;
- [ ] catálogo de comandos permitido;
- [ ] política para ações vindas de agente;
- [ ] registro de falhas.

### Critério de conclusão
Falha no Raspberry, LLM ou aplicação de usuário não pode manter movimento indefinido.

---

## Fase 6 — Gateway 2.0

### Atividades
- [ ] estados de conexão explícitos;
- [ ] heartbeat;
- [ ] fila com prioridade;
- [ ] cancelamento;
- [ ] retry configurável;
- [ ] telemetria estruturada;
- [ ] eventos;
- [ ] API versionada;
- [ ] testes unitários;
- [ ] métricas e diagnóstico.

### Critério de conclusão
Clientes de alto nível não precisam conhecer detalhes da serial.

---

## Fase 7 — Simulator

### Atividades
- [ ] dispositivo serial virtual;
- [ ] simulador Body Controller;
- [ ] simulador Head Controller;
- [ ] sensores configuráveis;
- [ ] cenários de falha;
- [ ] replay de telemetria;
- [ ] testes de protocolo.

### Critério de conclusão
Gateway e AI Runtime podem ser testados sem o robô físico.

---

## Fase 8 — CI

### Pipeline
- [ ] compile Mega;
- [ ] compile MCabeca;
- [ ] lint/test Gateway;
- [ ] protocol tests;
- [ ] compile Free Pascal AI Runtime;
- [ ] smoke test do simulador;
- [ ] validação de links;
- [ ] validação Yocto.

### Critério de conclusão
Push e pull request informam automaticamente regressões conhecidas.

---

## Fase 9 — Telemetria e diagnóstico

### Atividades
- [ ] modelo de estado unificado;
- [ ] health por módulo;
- [ ] autoteste;
- [ ] diagnóstico guiado;
- [ ] histórico;
- [ ] relatório de manutenção.

---

## Fase 10 — Task Engine 2.0

### Atividades
- [ ] tarefas;
- [ ] subtarefas;
- [ ] dependências;
- [ ] tentativas;
- [ ] cancelamento;
- [ ] evidências;
- [ ] resultado;
- [ ] persistência;
- [ ] auditoria.

---

## Fase 11 — RAG e Agent Runtime

### Atividades
- [ ] busca lexical melhorada;
- [ ] BM25/FTS;
- [ ] metadata;
- [ ] embeddings opcionais;
- [ ] busca híbrida;
- [ ] ferramentas tipadas;
- [ ] política de ações;
- [ ] confirmação humana para operações físicas relevantes.

---

## Fase 12 — Visão e voz

### Visão
- [ ] captura;
- [ ] detecção;
- [ ] tracking;
- [ ] integração pan/tilt;
- [ ] calibração;
- [ ] fusão câmera + distância.

### Voz
- [ ] STT;
- [ ] TTS;
- [ ] interação;
- [ ] controle de sessão;
- [ ] integração ao Task Engine.

---

## Fase 13 — Control Center

### Telas
- [ ] dashboard;
- [ ] estado;
- [ ] sensores;
- [ ] atuadores;
- [ ] câmera;
- [ ] tarefas;
- [ ] IA;
- [ ] logs;
- [ ] diagnóstico;
- [ ] manutenção;
- [ ] configuração.

---

## Fase 14 — Robotinics OS

### Atividades
- [ ] validar build ARM64 completo;
- [ ] consolidar recipes;
- [ ] serviços systemd;
- [ ] health checks;
- [ ] watchdog;
- [ ] configuração;
- [ ] atualização;
- [ ] imagem Raspberry Pi 4;
- [ ] imagem Raspberry Pi 5;
- [ ] procedimento de recuperação.

## Ordem recomendada de execução

```text
Firmware
  -> protocolo
  -> safety
  -> gateway
  -> simulador
  -> CI
  -> telemetria
  -> diagnóstico
  -> Task Engine
  -> RAG/agente
  -> visão/voz
  -> interface
  -> distribuição
```

A inteligência deve crescer sobre uma base física verificável, não substituir essa base.

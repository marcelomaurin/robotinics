# Agente de Documentação do Robotinics

## Objetivo

Permitir que uma IA ajude a manter a documentação sincronizada com código, hardware e arquitetura ao longo do tempo.

## Entradas

O agente lê:

- `AGENTS.md`;
- READMEs;
- código-fonte;
- `docs/rev3/`;
- histórico de commits quando disponível;
- resultados de compilação/teste;
- metadados de hardware documentados.

## Saídas

Pode produzir:

- relatório de inconsistências;
- links quebrados;
- comandos não documentados;
- pinos divergentes;
- arquivos sem README;
- documentação desatualizada;
- proposta de atualização;
- diff Markdown.

## Regra de evidência

Cada alteração documental deve indicar origem:

```text
SOURCE=CODE
SOURCE=README
SOURCE=REV3
SOURCE=TEST
SOURCE=USER
SOURCE=PROPOSAL
```

`PROPOSAL` nunca pode ser apresentado como funcionalidade existente.

## Fluxo

```text
scan repository
      |
      v
build module inventory
      |
      v
compare code <-> docs
      |
      v
classify divergence
      |
      v
generate patch
      |
      v
human review
      |
      v
commit
```

## Atualização por módulo

Quando o Mega mudar:

- revisar `Software/arduino/robotinics/README.*`;
- revisar protocolo;
- revisar integração Raspberry.

Quando MCabeca mudar:

- revisar comandos;
- pinagem;
- LEDs;
- laser;
- distância;
- integração Mega;
- visão se a interface angular mudar.

Quando Raspberry/IA mudar:

- revisar `Software/raspberry/AI/`;
- revisar `docs/ai/`;
- revisar variáveis de ambiente;
- revisar dependências TCHATGPT;
- revisar política de internet.

## Idiomas

Para mudanças estruturais:

1. atualizar Português;
2. replicar semanticamente para English;
3. replicar semanticamente para Español.

Não traduzir nomes de comandos ou protocolo.

## Links

Preferir links relativos para arquivos internos.

O agente deve detectar referências a arquivos removidos ou renomeados.

## Estado documental

Use quando necessário:

```text
CURRENT
HISTORICAL
DEPRECATED
PROPOSED
```

## Atualização em tempo útil

O agente pode rodar:

- a cada PR;
- a cada release;
- quando protocolo mudar;
- quando novo módulo surgir;
- quando firmware mudar comandos ou pinagem.

Ele deve gerar proposta ou aviso. Não deve alterar `master` automaticamente sem revisão.

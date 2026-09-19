# Task Engine 2.0 — Robotinics Rev. 4

## Objetivo

O Task Engine transforma uma pergunta ou objetivo em uma unidade persistente e auditável de trabalho.

Ele não controla hardware diretamente. Ações físicas continuam passando pelo Gateway, catálogo de comandos e Safety Layer.

## Schema

Cada tarefa persistida possui:

```text
schema_version
id
question
status
cancelled
cancel_reason
result
created_at
updated_at
steps
subtasks
evidence
audit
```

## Estados da tarefa

Estados usados atualmente:

```text
RUNNING
DONE
ERROR
CANCELLED
```

## Subtarefas

Cada subtarefa possui:

```text
id
name
kind
depends_on
status
attempts
detail
created_at
started_at
finished_at
```

Estados:

```text
PENDING
RUNNING
DONE
ERROR
CANCELLED
```

## Dependências

`depends_on` contém IDs de subtarefas separados por vírgula.

Uma subtarefa só pode iniciar quando todas as dependências deixaram os estados:

```text
PENDING
RUNNING
```

Isso permite que uma etapa de raciocínio continue mesmo quando uma fonte opcional terminou com `ERROR`, desde que o erro esteja registrado como evidência/auditoria.

## Tentativas

Cada chamada de `StartSubTask` incrementa `attempts`.

Isso permite registrar retries de fontes externas ou operações de alto nível sem perder o histórico da tarefa.

## Evidências

Evidências possuem:

```text
timestamp
source
kind
detail
```

O AI Runtime já registra:

- pergunta original;
- estado do Gateway;
- catálogo;
- histórico;
- contexto documental;
- contexto externo quando habilitado;
- resposta ou erro do LLM.

## Resultado

O resultado final é persistido separadamente em `result`.

Uma tarefa concluída não depende de logs textuais para reconstruir a resposta apresentada ao usuário.

## Cancelamento

`Cancel(reason)`:

- marca a tarefa como `CANCELLED`;
- registra o motivo;
- cancela subtarefas ainda `PENDING` ou `RUNNING`;
- grava evento de auditoria.

Cancelamento de uma ação física deve continuar sendo propagado ao Gateway. O Task Engine não substitui o mecanismo de cancelamento do Gateway 2.0.

## Auditoria

Eventos incluem, entre outros:

```text
task_created
status
step
subtask_created
subtask_running
subtask_done
subtask_error
task_cancelled
evidence
result
```

Cada evento contém timestamp e detalhe.

## Persistência

Arquivos são salvos em:

```text
<ROBOTINICS_STATE_PATH>/tasks/<task-id>.json
```

A gravação usa arquivo temporário seguido de rename para reduzir risco de arquivo parcialmente escrito.

## Integração atual do AI Runtime

Fluxo atual:

```text
Entender solicitação
        |
        +--> Coletar estado do robô
        |
        +--> Consultar documentação
        |
        +--> Consultar fonte externa
                    |
                    v
             Gerar resposta final
```

A etapa final depende das três fontes de contexto terem terminado, com sucesso ou erro documentado.

## Segurança

O Task Engine pode planejar e registrar ações, mas:

- não escreve PWM;
- não movimenta servos diretamente;
- não envia texto arbitrário à serial;
- não transforma conteúdo web em comando físico;
- deve utilizar Gateway/catalog/policy para qualquer ação física futura.

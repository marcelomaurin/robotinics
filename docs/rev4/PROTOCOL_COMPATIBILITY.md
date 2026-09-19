# Compatibilidade e evolução do protocolo

## Objetivo

Permitir modernização interna do Robotinics sem quebrar clientes e hardware existentes.

## Regra principal

A refatoração da Rev. 4 pode alterar a implementação interna, mas não deve alterar silenciosamente:

- nome de comando;
- formato aceito;
- baud rate;
- porta física;
- semântica do comando;
- pinagem;
- limite mecânico;
- resposta usada por clientes existentes.

## Comandos legados observados

O firmware atual e o Gateway já trabalham com comandos como:

```text
FRENTE
RE
PARA
GESQ
GDIR
CLS
GPS
ACEL
ULTRA
ULTRA1
ULTRA2
GAS
CORR
MAN
VER
TESTE
LCDCLEAR
SETMONITOR=ON|OFF
GCABECAESQ=<valor>
GCABECADIR=<valor>
GBDIR=<valor>
GBESQ=<valor>
GPGARRADIR=<valor>
GPGARRAESQ=<valor>
GPPUNHOESQ=<valor>
GPPUNHODIR=<valor>
```

O MCabeca possui ainda comandos encapsulados pelo Gateway no namespace `MCAB:`.

Esta lista é um baseline documental e deve ser confirmada contra o código sempre que houver alteração.

## Estratégia de evolução

### Protocolo legado

Continua sendo aceito:

```text
FRENTE
GCABECADIR=30
```

### Extensões futuras

Podem ser adicionadas sem remoção imediata do formato legado:

```text
IDENTIFY
CAPABILITIES
HEALTH
PING
```

Respostas futuras estruturadas devem possuir prefixo inequívoco, para não serem confundidas com mensagens humanas ou logs.

Exemplo conceitual:

```text
RBT:OK:PARA
RBT:ERR:INVALID_ARG
RBT:EVENT:COLLISION_WARNING
RBT:STATE:MOTION:STOPPED
```

Esses formatos são **propostos**, não são declarados como implementados nesta documentação.

## Versionamento

Proposta:

```text
Device Protocol 1.x = compatibilidade com comandos históricos
Device Protocol 2.x = protocolo estruturado futuro, se necessário
```

Mudança de versão major deve significar quebra explícita de compatibilidade.

## Descoberta de capacidades

Proposta futura:

```text
IDENTIFY
CAPABILITIES
```

O objetivo é permitir que o Raspberry descubra quais recursos estão presentes sem assumir configuração fixa.

## Segurança

Comandos recebidos da camada cognitiva devem:

1. estar no catálogo;
2. ter argumentos validados;
3. respeitar limites físicos;
4. passar pela política de segurança;
5. gerar resultado observável.

Texto de LLM, documentação ou internet nunca deve ser encaminhado diretamente à serial.

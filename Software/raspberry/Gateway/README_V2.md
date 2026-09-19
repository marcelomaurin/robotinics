# Robotinics Gateway 2.0

Gateway local entre aplicações de alto nível e o Body Controller.

## Compatibilidade

As rotas `/v1` continuam disponíveis.

A Rev. 4 adiciona `/v2` sem remover a API anterior.

## Estados de conexão

```text
DISCONNECTED
CONNECTING
CONNECTED
DEGRADED
```

O estado está disponível em:

```text
GET /v2/state
```

## Prioridades

A fila é uma `PriorityQueue`.

Ordem padrão:

```text
0   emergency
10  high
50  normal
90  low
```

`PARA` usa prioridade 0.

Heartbeat interno `PING` usa prioridade 90.

## Envio síncrono

```http
POST /v2/command
Content-Type: application/json

{
  "command": "IDENTIFY"
}
```

## Envio assíncrono

```http
POST /v2/command

{
  "command": "ULTRA1",
  "async": true
}
```

Resposta:

```json
{
  "ok": true,
  "request_id": "...",
  "priority": 50
}
```

Consultar:

```text
GET /v2/request/<request_id>
```

## Cancelamento

```http
POST /v2/cancel/<request_id>

{
  "reason": "operator_cancel"
}
```

Se a requisição ativa cancelada for de movimento, o Gateway agenda um `PARA` de prioridade máxima.

## Retry

Retry automático é aplicado por padrão apenas a comandos classificados como seguros para repetição, por exemplo:

- `PING`;
- `IDENTIFY`;
- `CAPABILITIES`;
- `SAFETY`;
- consultas de sensores.

Movimentos não recebem retry automático por padrão.

Configuração:

```text
ROBOTINICS_COMMAND_RETRIES
```

Também é possível definir `retries` por requisição.

## Eventos

```text
GET /v2/events
GET /v2/events?limit=20
```

Eventos incluem:

- conexão;
- requisição enfileirada;
- retry;
- cancelamento;
- conclusão;
- safety stop;
- linhas estruturadas do dispositivo.

## Métricas

`GET /v2/state` retorna:

```text
submitted
completed
failed
cancelled
retried
serial_reconnects
events
```

## Telemetria

O Gateway converte respostas legadas conhecidas para estado estruturado quando possível:

- `ULTRA` -> `sensors.ultra_cm`;
- `ULTRA1` -> `sensors.ultra1_cm`;
- `ULTRA2` -> `sensors.ultra2_cm`;
- `CORR` -> `sensors.current`;
- `GAS` -> `sensors.gas`;
- `MCAB:DIST` -> `head.distance_cm`;
- `MCAB:POS` -> posição da cabeça.

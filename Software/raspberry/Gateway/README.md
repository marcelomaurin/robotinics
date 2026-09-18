# RobotGateway

O RobotGateway é a única camada do Raspberry autorizada a conversar diretamente com o Arduino Mega.

## API local

Por padrão:

```text
http://127.0.0.1:8765
```

Endpoints:

```text
GET  /v1/ping
GET  /v1/state
GET  /v1/catalog
GET  /v1/history?limit=20
POST /v1/command
```

Exemplo:

```bash
curl http://127.0.0.1:8765/v1/state
```

Comando:

```bash
curl -X POST http://127.0.0.1:8765/v1/command \
  -H 'Content-Type: application/json' \
  -d '{"command":"MCAB:DIST","timeout":5}'
```

O gateway cria `request_id`, serializa os comandos e associa a resposta ao prompt `$>` do protocolo do Mega.

A API escuta apenas localhost por padrão.

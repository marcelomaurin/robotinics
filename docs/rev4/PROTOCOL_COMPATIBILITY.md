# Robotinics Device Protocol 1.x

## Status

Esta especificação descreve o protocolo textual compatível com o firmware histórico do Robotinics e suas extensões compatíveis da Rev. 4.

O objetivo é permitir que um cliente implemente integração com o Body Controller sem precisar ler o firmware.

## Transporte

### Body Controller / Arduino Mega

Canal principal atual:

```text
USB Serial
115200 bps
8N1
linha terminada por LF
```

Bluetooth legado:

```text
9600 bps
linha terminada por LF
```

Canal para MCabeca:

```text
9600 bps
```

## Modelo de requisição

Cada comando é enviado como uma única linha:

```text
COMMAND\n
```

O Body Controller pode emitir zero ou mais linhas de resposta e termina o processamento do comando com:

```text
$>
```

O Gateway usa esse prompt como marcador de conclusão da requisição.

## Compatibilidade

Protocol 1.x preserva:

- nomes dos comandos históricos;
- semântica dos comandos;
- formato textual;
- prompt `$>`;
- baud rates existentes;
- namespace `MCAB:`.

Extensões 1.x podem adicionar novos comandos e novas linhas estruturadas, desde que clientes antigos continuem funcionando.

## Categorias de comandos

### Movimento

```text
FRENTE
RE
PARA
GESQ
GDIR
```

`PARA` possui prioridade lógica no parser.

Movimento contínuo é protegido por SafetyController:

- watchdog de controle;
- timeout máximo de ordem;
- parada por obstáculo.

### Sensores

```text
ULTRA
ULTRA1
ULTRA2
ACEL
GAS
CORR
GPS
```

### Servos do corpo

```text
GCABECAESQ=<0..180>
GCABECADIR=<0..180>
GBDIR=<0..180>
GBESQ=<0..180>
GPGARRADIR=<0..180>
GPGARRAESQ=<0..180>
GPPUNHOESQ=<0..180>
GPPUNHODIR=<0..180>
```

O Gateway valida a faixa 0..180 antes de encaminhar.

### Interface local

```text
CLS
LCDCLEAR
MSG1:<texto>
MSG2:<texto>
SETMONITOR=ON
SETMONITOR=OFF
```

### Diagnóstico / manutenção

```text
MAN
VER
TESTE
PING
SAFETY
IDENTIFY
CAPABILITIES
```

## Heartbeat

### PING

Entrada:

```text
PING
```

Resposta:

```text
PONG
$>
```

O Gateway utiliza PING como heartbeat interno enquanto existe movimento ativo.

## Segurança

### SAFETY

Entrada:

```text
SAFETY
```

Resposta atual:

```text
SAFETY:MOTION:ACTIVE
SAFETY:LAST_STOP:none
$>
```

ou:

```text
SAFETY:MOTION:STOPPED
SAFETY:LAST_STOP:control_watchdog
$>
```

### Eventos de parada

O Mega emite:

```text
SAFETY:STOP:<reason>
```

Reasons implementados:

```text
command
front_obstacle
rear_obstacle
motion_timeout
control_watchdog
```

Essas linhas são eventos observáveis e podem ocorrer fora da resposta de um comando normal.

## Health e autoteste

### HEALTH

Entrada:

```text
HEALTH
```

O Body Controller retorna linhas estruturadas:

```text
RBT:HEALTH:BODY:OK
RBT:HEALTH:SAFETY:IDLE
RBT:HEALTH:MOTION:STOPPED
RBT:TELEM:ULTRA_RE_CM:<valor>
RBT:TELEM:ULTRA_FRONT_CM:<valor>
RBT:TELEM:ULTRA_HEAD_CM:<valor>
$>
```

O Head Controller aceita:

```text
MCAB:HEALTH
```

e responde por meio da bridge com:

```text
MCAB:HEALTH:HEAD:OK
MCAB:POS:<x>,<y>
```

O Gateway 2.0 usa esses comandos em um autoteste não motor. A sequência inicia obrigatoriamente com `PARA` e não executa `FRENTE`, `RE`, `GESQ`, `GDIR` nem testes mecânicos.

## Identificação

### IDENTIFY

Entrada:

```text
IDENTIFY
```

Resposta implementada:

```text
RBT:IDENTIFY:BODY:MEGA2560:1.3
$>
```

Formato:

```text
RBT:IDENTIFY:<role>:<board>:<firmware_version>
```

## Descoberta de capacidades

### CAPABILITIES

Entrada:

```text
CAPABILITIES
```

Resposta atual contém uma linha por capacidade:

```text
RBT:CAP:MOTION
RBT:CAP:SERVOS
RBT:CAP:ULTRASONIC
RBT:CAP:ANALOG_SENSORS
RBT:CAP:GPS
RBT:CAP:LCD
RBT:CAP:MCABECA_BRIDGE
RBT:CAP:SAFETY_WATCHDOG
$>
```

Formato:

```text
RBT:CAP:<capability>
```

Clientes devem ignorar capacidades desconhecidas.

## MCabeca

O Gateway e o Mega usam namespace:

```text
MCAB:<comando>
```

Exemplos aceitos pelo Gateway:

```text
MCAB:DIST
MCAB:GETPOS
MCAB:CENTER
MCAB:LASERON
MCAB:LASEROFF
MCAB:SCANNING
MCAB:POINT:90,45
MCAB:LEDAZUL=ON
MCAB:LEDVERDE=OFF
MCAB:LEDVERMELHO=ON
MCAB:OLHOS=ON
MCAB:LIGHTAUTO=OFF
```

O Mega encaminha o conteúdo após `MCAB:` ao Head Controller.

## Erros

O protocolo legado ainda utiliza a mensagem:

```text
Comando não reconhecido!
```

A Rev. 4 reserva o prefixo estruturado:

```text
RBT:ERR:<code>
```

para evolução futura.

Enquanto `RBT:ERR` não estiver implementado em todos os controladores, clientes devem continuar aceitando as mensagens legadas.

## Prefixos reservados

A Rev. 4 reserva:

```text
RBT:IDENTIFY:
RBT:CAP:
RBT:OK:
RBT:ERR:
RBT:EVENT:
RBT:STATE:
SAFETY:
MCAB:
```

## Versionamento

### Device Protocol 1.x

Características:

- protocolo textual;
- compatibilidade com comandos históricos;
- prompt `$>`;
- extensões aditivas permitidas.

### Device Protocol 2.x

Reservado para uma futura quebra explícita de compatibilidade, caso seja necessária.

Nenhuma migração para 2.x deve acontecer silenciosamente.

## Política de depreciação

Para remover ou alterar semanticamente um comando existente:

1. documentar o comando afetado;
2. manter período de compatibilidade;
3. oferecer substituto;
4. atualizar Gateway, simulador e testes;
5. validar no hardware;
6. somente então considerar remoção numa versão major futura.

## Segurança para clientes

Um cliente não deve:

- enviar texto de LLM diretamente à serial;
- inventar comandos;
- assumir que envio significa execução;
- assumir que movimento continuará indefinidamente.

Um cliente deve:

- usar catálogo validado;
- esperar `$>` quando aplicável;
- observar eventos `SAFETY:STOP`;
- consultar estado após ações críticas;
- tratar perda de comunicação como estado inseguro/desconhecido.

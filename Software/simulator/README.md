# Robotinics Simulator — Rev. 4

Simulador serial do Body Controller (Arduino Mega) e do MCabeca para desenvolvimento sem hardware físico.

## O que simula

- comandos de movimento;
- `PING/PONG`;
- `SAFETY`;
- `IDENTIFY`;
- `CAPABILITIES`;
- ultrassom dianteiro, traseiro e cabeça;
- corrente e gás;
- bridge `MCAB:`;
- posição da cabeça;
- laser e LEDs;
- watchdog de controle;
- timeout de movimento;
- colisão dianteira/traseira;
- falhas de resposta/desconexão em nível de modelo.

## Serial virtual

Execute:

```bash
python3 Software/simulator/robotinics_simulator.py
```

A primeira linha exibida será o pseudo-terminal, por exemplo:

```text
/dev/pts/7
```

Esse caminho pode ser usado diretamente pelo Gateway:

```bash
ROBOTINICS_SERIAL_PORT=/dev/pts/7 \
python3 Software/raspberry/Gateway/robotinics_gateway.py
```

Assim o Gateway usa o mesmo código e a mesma biblioteca serial usados com o Arduino Mega real.

## Snapshot

```bash
python3 Software/simulator/robotinics_simulator.py --snapshot
```

## Testes

```bash
python3 -m unittest discover -s Software/simulator/tests -p "test_*.py" -v
```

Os testes incluem integração real Gateway -> pyserial -> pseudo-terminal -> simulador.

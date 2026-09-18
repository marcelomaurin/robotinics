# MCabeca — Módulo de Percepção Ativa

[Robotinics](../../../README.md) · [Arduino](../README.md) · [English](README.en.md) · [Español](README.es.md)

O **MCabeca** é um módulo especializado do Robotinics baseado em **Arduino Nano / ATmega328P**.

Sua função é executar movimentos e operações físicas da cabeça do robô de maneira simples, previsível e compatível com o controlador principal.

## Componentes controlados

O módulo controla diretamente:

- servo do eixo horizontal;
- servo do eixo vertical;
- apontador laser;
- LED azul;
- LED verde;
- LED vermelho;
- iluminação dos olhos;
- sensor ultrassônico frontal da cabeça.

## Papel do laser

O laser é utilizado como **apontador e referência óptica**.

Ele não tem finalidade de arma.

A combinação dos dois servos permite orientar o ponto laser por ângulos conhecidos. Isso pode ser associado à câmera do Robotinics para criar experimentos de percepção ativa.

## Relação com a câmera

A câmera não é processada pelo Arduino Nano.

O fluxo conceitual é:

```text
Câmera
  │
  ▼
Raspberry Pi
  ├── calibração
  ├── detecção do ponto laser
  ├── visão computacional
  ├── estimativa de profundidade
  └── planejamento da varredura
            │
            ▼
       ângulo X / Y
            │
            ▼
        MCabeca
```

O Raspberry Pi converte informações visuais em ângulos.

O Nano apenas recebe esses ângulos e posiciona os servos.

## Percepção ativa

Esse arranjo permite estudar:

- apontamento visual de objetos;
- varredura horizontal e vertical;
- scanning de regiões;
- detecção do ponto laser na imagem;
- auxílio à visão monocular;
- triangulação feita no Raspberry;
- reconstrução aproximada de perfil;
- combinação de profundidade visual e ultrassônica.

## Sensor ultrassônico

O sensor fornece uma medida independente de distância.

Ele pode ser utilizado como:

- sensor de proximidade;
- referência de segurança;
- validação grosseira da estimativa visual;
- dado adicional para fusão de sensores.

## LEDs

Os LEDs devem poder ser comandados independentemente.

A modernização proposta permite comandos individuais para:

```text
LEDAZUL=ON
LEDAZUL=OFF
LEDVERDE=ON
LEDVERDE=OFF
LEDVERMELHO=ON
LEDVERMELHO=OFF
OLHOS=ON
OLHOS=OFF
```

Também existe a ideia de um modo automático de iluminação:

```text
LIGHTAUTO=ON
LIGHTAUTO=OFF
```

Quando um LED é comandado manualmente, o modo automático deve deixar de sobrescrever esse estado.

## Posicionamento angular

O MCabeca trabalha apenas com ângulos.

Exemplo:

```text
POINT:90,45
```

A calibração que transforma pixel de câmera em ângulo é responsabilidade do Raspberry Pi.

Comandos complementares propostos:

```text
GETPOS
CENTER
```

## Distância

O comando histórico:

```text
ULTRA
```

continua válido.

Para comunicação entre dispositivos, uma resposta mais estruturada pode ser utilizada:

```text
DIST
MCAB:DIST:42.50
```

## Compatibilidade com o Mega

O MCabeca se comunica diretamente com o equipamento principal.

A proposta atual alinha o canal serial em 9600 bps e utiliza respostas identificadas com `MCAB:`, permitindo ao Mega reconhecer que a mensagem veio do módulo de cabeça.

## Limitações do Arduino Nano

O ATmega328P possui recursos limitados de RAM e flash.

Por isso, a implementação deve:

- evitar uso excessivo de `String`;
- usar buffers fixos;
- armazenar textos constantes em flash quando possível;
- manter o parser simples;
- evitar bibliotecas não utilizadas;
- deixar visão e calibração fora do microcontrolador.

## Firmware

O PR #4 refatora o firmware histórico preservando pinagem e comandos legados, mas tornando o código mais adequado ao Arduino Nano e à integração com o Mega.


## Pinout

O mapeamento entre pinos do Arduino Nano, portas do ATmega328P e funções do MCabeca está documentado em [docs/hardware/pinout/MCABECA_ATMEGA328P.md](../../../docs/hardware/pinout/MCABECA_ATMEGA328P.md).

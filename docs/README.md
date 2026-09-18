# Documentação do Robotinics

[Projeto principal](../README.md) · [English](README.en.md) · [Español](README.es.md)

Esta pasta reúne documentação histórica e material didático relacionado ao Robotinics.

## Histórico e origem

O Robotinics foi apresentado originalmente em **2015** como **Trabalho de Conclusão de Curso (TCC)** do curso de **Técnico em Mecânica Industrial** da **Etec José Martimiano da Silva**, em Ribeirão Preto/SP, unidade do **Centro Paula Souza**.

O projeto surgiu com uma proposta multidisciplinar, reunindo mecânica, estrutura física, eletrônica, sensores, acionamentos, microcontroladores e software. O repositório atual preserva materiais de diferentes fases dessa evolução, incluindo arquivos mecânicos, placas, códigos, documentação didática e versões posteriores do sistema.

Instituição: [Etec José Martimiano da Silva – Centro Paula Souza](https://www.cps.sp.gov.br/etecs/etec-jose-martimiano-da-silva/)

## Documentação principal

A referência mais recente do projeto é a **Robotinics Rev. 3**, disponível em [rev3/README.md](rev3/README.md), com edições em português e inglês, manuscritos-fonte e arquivos de reconstrução.

A Rev. 3 consolida a arquitetura moderna do Robotinics, incluindo Raspberry Pi, TCHATGPT, agentes, visão, voz, RAG e controle supervisionado.

## Continuação de IA

A evolução posterior da arquitetura de IA está documentada em [ai/README.md](ai/README.md).

Essa documentação descreve a integração com internet, o runtime no Raspberry Pi e um agente específico para manter os READMEs sincronizados com o código.

## Material histórico

O repositório também preserva **Projetos IoT com Arduino e Raspberry** como documentação histórica.

Esse conteúdo registra conceitos, montagens, experimentos e etapas associadas ao desenvolvimento do projeto.

## Papel desta pasta

O objetivo de `docs/` é concentrar material que não pertence diretamente ao código-fonte ou aos arquivos de fabricação.

Exemplos de conteúdo adequado:

- manual de montagem;
- arquitetura;
- protocolo;
- pinagem;
- tutoriais;
- diagramas;
- histórico;
- imagens técnicas;
- procedimentos de teste.

## Organização futura sugerida

```text
docs/
├── architecture/
├── assembly/
├── electronics/
├── firmware/
├── protocol/
├── raspberry/
├── vision/
└── history/
```

## Documentação modular

A documentação atual está sendo distribuída também em READMEs próximos aos respectivos módulos.

Isso facilita a navegação:

- eletrônica documentada em `Eletronic/`;
- mecânica em `Mecanic/`;
- software em `Software/`;
- Mega e MCabeca em suas próprias pastas.

A pasta `docs/` deve concentrar materiais mais extensos e transversais ao projeto.

## Idiomas

A documentação principal utiliza:

- Português;
- English;
- Español.

A versão em português é usada como referência principal quando não houver outra indicação.


## Pinout dos controladores

A documentação de pinout dos controladores está em [hardware/pinout/README.md](hardware/pinout/README.md), cobrindo Arduino Mega/ATmega2560, MCabeca/ATmega328P e Raspberry Pi 4/5.

# Banco de Dados do Robotinics

[Projeto principal](../../README.md) · [Software](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório reúne os artefatos de banco de dados utilizados pelo Robotinics.

## Estrutura

Atualmente existe conteúdo relacionado a MySQL em:

```text
database/
└── mysql/
```

O banco foi utilizado como suporte às camadas de aplicação e interface do projeto.

## Papel no sistema

O banco não deve controlar diretamente motores ou atuadores.

Sua função é persistir informações de mais alto nível, por exemplo:

- configurações;
- dispositivos;
- eventos;
- telemetria;
- comandos registrados;
- usuários;
- estados históricos;
- dados produzidos por aplicações web.

## Separação de responsabilidades

```text
hardware
   │
   ▼
Arduino
   │
   ▼
Raspberry / aplicação
   │
   ▼
database
```

Essa separação evita acoplar persistência com controle físico em tempo real.

## Evolução recomendada

Para uma nova revisão do Robotinics, seria útil documentar:

- esquema atual;
- tabelas;
- relacionamentos;
- dados obrigatórios;
- scripts de criação;
- migrações;
- dados de exemplo;
- política de versionamento.

Credenciais e senhas nunca devem ser armazenadas diretamente no repositório.

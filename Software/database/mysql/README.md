# MySQL — Robotinics

[Database](../README.md) · [English](README.en.md) · [Español](README.es.md)

Este diretório contém os artefatos MySQL do Robotinics.

## Objetivo

A camada MySQL persiste informações de aplicação e histórico. Ela não participa do controle físico em tempo real.

Usos adequados incluem:

- configurações;
- cadastro de dispositivos;
- telemetria;
- eventos;
- registros de comando;
- usuários;
- estados históricos.

## Boas práticas

- mantenha scripts de criação versionados;
- não armazene senhas reais no repositório;
- use migrações para alterações estruturais;
- documente tabelas e relacionamentos;
- mantenha dados de exemplo separados de dados reais.

## Relação com o robô

O fluxo esperado é:

```text
Arduino → Raspberry/aplicação → MySQL
```

O banco nunca deve ser dependência direta de uma rotina crítica de motor ou segurança.

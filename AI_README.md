# Robotinics — Entrada rápida para IA

Este arquivo fornece contexto rápido a um agente de IA antes de modificar o projeto.

## O que é o Robotinics

Robotinics é uma plataforma robótica multidisciplinar iniciada em 2015 como TCC de Técnico em Mecânica Industrial e posteriormente expandida com Arduino, Raspberry Pi, software, visão e IA.

## Arquitetura

- Raspberry Pi: processamento de alto nível;
- Arduino Mega: controle físico principal;
- Arduino Nano / MCabeca: cabeça robótica;
- TCHATGPT: camada de IA da Rev. 3 e continuidade atual;
- internet: ferramenta consultiva controlada pelo Raspberry;
- RAG: documentação local do próprio projeto.

## Regra principal

**IA sugere, interpreta, pesquisa e planeja. O controle físico é validado e executado por camadas determinísticas.**

## Antes de alterar qualquer coisa

Leia `AGENTS.md`.

Depois leia o README do módulo afetado e, quando relevante, `docs/rev3/`.

## Continuação de IA

A proposta atual está em `docs/ai/` e `Software/raspberry/AI/`.

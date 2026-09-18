# Saída de Voz — Histórico

[Raspberry Output](../README.md) · [Implementação atual](../../Voice/README.md)

Este diretório contém **somente a implementação histórica** de voz do Robotinics.

## Estado

**DEPRECATED**

A integração baseada em eSpeak não faz mais parte da imagem atual do Raspberry Pi.

A implementação vigente está em:

- [Software/raspberry/Voice](../../Voice/README.md)

Ela mantém as mesmas entradas públicas:

```bash
robotinics-speak "texto"
robotinics-read-file arquivo.txt
```

mas utiliza uma aplicação Lazarus/Free Pascal com `TAIVoiceSynthesizer` da biblioteca TCHATGPT e a API de síntese de voz.

Os arquivos eSpeak permanecem nesta pasta apenas como registro histórico do projeto.

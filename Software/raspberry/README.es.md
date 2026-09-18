# Raspberry Pi en Robotinics

[Proyecto principal](../../README_ES.md) · [Software](../README.es.md) · [Português](README.md) · [English](README.en.md)

Raspberry Pi representa la capa de procesamiento de alto nivel.

## Funciones

Puede concentrar:

- visión por computador;
- cámara;
- calibración;
- detección del punto láser;
- triangulación;
- scanning;
- lógica de misión;
- integración de sensores;
- banco de datos;
- servicios externos;
- IA opcional.

La calibración entre cámara, láser y servos pertenece al Raspberry. MCabeca sólo debe recibir ángulos y comandos físicos.

Arduino Mega continúa siendo responsable del control inmediato y de la seguridad local.


## Capa de IA

La continuación actual define un runtime de IA en Raspberry Pi basado en TCHATGPT, RAG, acceso controlado a internet, visión, voz y telemetría.

Consulte [AI/README.es.md](AI/README.es.md) y [../../docs/ai/README.es.md](../../docs/ai/README.es.md).


## Imagen Yocto

La imagen reproducible del computador de a bordo se mantiene en [yocto/README.es.md](yocto/README.es.md), junto al runtime Raspberry Pi que empaqueta.


## Voz

La implementación actual de voz está en [Voice/README.es.md](Voice/README.es.md). Sustituye eSpeak por una aplicación Lazarus/Free Pascal usando `TAIVoiceSynthesizer` de TCHATGPT y conserva los comandos públicos `robotinics-speak` y `robotinics-read-file`.

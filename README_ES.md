# Robotinics

[Português](README.md) · [English](README_EN.md) · [Español](README_ES.md)

![Robotinics](Mecanic/solidwork/robotinics.JPG)

Robotinics es una plataforma abierta de robótica, automatización y experimentación diseñada para integrar **mecánica, electrónica, firmware embebido, Raspberry Pi y software de aplicación**.

El objetivo no es ofrecer solamente un robot terminado. Robotinics funciona como una plataforma técnica evolutiva que puede estudiarse, modificarse, reproducirse y ampliarse.

## Origen del proyecto

Robotinics nació en **2015** como **Trabajo de Conclusión de Curso (TCC)** del curso de **Técnico en Mecánica Industrial**, presentado en la **Etec José Martimiano da Silva**, en Ribeirão Preto, São Paulo, Brasil, unidad del **Centro Paula Souza**.

Este origen explica el carácter multidisciplinario del proyecto desde el comienzo: Robotinics no fue concebido solamente como software o electrónica, sino como un sistema integrado de **mecánica, fabricación de piezas, electrónica, accionamientos, sensores, microcontroladores y software**.

Después del proyecto académico original, Robotinics continuó evolucionando como plataforma experimental, incorporando nuevas revisiones mecánicas, placas electrónicas, Arduino, Raspberry Pi, visión computacional y otros módulos de software.

Institución: [Etec José Martimiano da Silva – Centro Paula Souza](https://www.cps.sp.gov.br/etecs/etec-jose-martimiano-da-silva/)

## Alcance

El proyecto incluye:

- modelos CAD y piezas imprimibles;
- esquemas electrónicos y PCB;
- Arduino Mega como controlador principal;
- Arduino Nano como controlador MCabeca;
- motores, servos y sensores;
- puntero láser y ultrasonido;
- integración con Raspberry Pi;
- base de datos;
- interfaz web histórica;
- documentación educativa e histórica.

## Arquitectura

```text
                       Raspberry Pi
                visión / integración / lógica
                            │
                            ▼
                      Arduino Mega
                controlador físico principal
                 /        │          \
             motores    sensores     servos
                            │
                            ▼
                     MCabeca / Nano
                ┌──────────┼──────────┐
              Servo X    Servo Y    Ultrasonido
                            │
                        Láser / LEDs
```

Raspberry Pi concentra procesamiento de alto nivel. Arduino Mega controla la mayor parte del hardware físico. MCabeca es un periférico especializado de la cabeza.

## Módulos principales

| Módulo | Función |
|---|---|
| [Electrónica](Eletronic/README.es.md) | esquemas, PCB y alimentación |
| [Mecánica](Mecanic/README.es.md) | CAD, ensamblajes y piezas |
| [Software](Software/README.es.md) | software embebido y de alto nivel |
| [Arduino](Software/arduino/README.es.md) | firmware de microcontroladores |
| [Mega](Software/arduino/robotinics/README.es.md) | controlador físico principal |
| [MCabeca](Software/arduino/MCabeca/README.es.md) | módulo activo de cabeza |
| [Raspberry](Software/raspberry/README.es.md) | procesamiento de alto nivel |
| [Base de datos](Software/database/README.es.md) | persistencia |
| [Web](Software/site/README.es.md) | interfaz histórica |
| [Documentación](docs/README.es.md) | manuales y material técnico |

## Arduino Mega

Arduino Mega se utiliza por la gran cantidad de E/S necesarias. Controla motores, servos, sensores, GPS, LCD, Bluetooth, RF y comunicaciones.

## MCabeca

MCabeca utiliza Arduino Nano y controla dos ejes de servo, puntero láser, LEDs independientes, ojos y sensor ultrasónico.

No realiza visión ni calibración de cámara.

## Percepción activa

Raspberry Pi puede utilizar la cámara y el láser para:

1. capturar la imagen;
2. detectar el punto láser;
3. aplicar calibración;
4. convertir píxeles en ángulos;
5. comandar MCabeca;
6. combinar la información visual con la distancia ultrasónica.

Esto permite experimentar con scanning, apuntado visual, ayuda a visión monocular y fusión de sensores.

El láser es una referencia óptica y visual, no un arma.

## División de responsabilidades

Raspberry Pi debe manejar visión, calibración, triangulación, lógica de misión, integración e IA opcional.

Los microcontroladores deben manejar motores, servos, sensores, LEDs, láser y seguridad local simple.

## Estructura

```text
robotinics/
├── Eletronic/
├── Mecanic/
├── Software/
│   ├── arduino/
│   ├── database/
│   ├── raspberry/
│   └── site/
└── docs/
```

## Modernización

- PR #3 — refactor del firmware Arduino Mega;
- PR #4 — optimización de MCabeca para Arduino Nano.

La meta es mejorar la arquitectura sin exigir reemplazo del hardware existente.

## Política de documentación

El README raíz explica la plataforma completa. Cada módulo mantiene su propia documentación y cada idioma utiliza un archivo separado.

Idiomas principales:

- Portugués;
- Inglés;
- Español.

## Autor

**Marcelo Maurin Martins**

- GitHub: [marcelomaurin](https://github.com/marcelomaurin)
- Sitio: [Maurinsoft](https://maurinsoft.com.br)

Robotinics es una plataforma experimental y educativa. Utilice prácticas adecuadas de seguridad con motores, alimentación, baterías, piezas móviles y punteros láser.

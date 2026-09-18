# Mecânica do Robotinics

[Projeto principal](../README.md) · [English](README.en.md) · [Español](README.es.md)

A pasta `Mecanic` reúne a estrutura física do Robotinics: modelos CAD, montagens e peças destinadas à impressão 3D.

## Objetivo

A mecânica faz parte da arquitetura do projeto. O Robotinics foi concebido para que software, eletrônica e estrutura física possam evoluir em conjunto.

O repositório não contém apenas uma carcaça: ele inclui peças funcionais relacionadas a braços, corpo, cabeça, suportes e integração dos componentes eletrônicos.

## Estrutura

### `solidwork/`

Contém arquivos de peças e montagens em SolidWorks.

Entre os arquivos existentes estão:

- montagem completa do Robotinics;
- corpo;
- bases;
- braços;
- suporte do laser;
- suporte do Raspberry Pi;
- peças de cabeça;
- extensões e suportes auxiliares.

Também existem imagens de referência da montagem.

### `stl/`

Contém arquivos exportados para impressão 3D.

Entre as peças disponíveis estão:

- base do braço;
- extensão do braço;
- corpo inferior e superior;
- placa da cabeça;
- partes inferior e superior da cabeça;
- prolongadores;
- suporte do laser;
- suporte do Raspberry Pi.

## Cabeça e laser

A estrutura da cabeça foi projetada para acomodar o módulo MCabeca.

O conjunto possui:

- dois eixos de movimento por servo;
- suporte para apontador laser;
- integração com sensor ultrassônico;
- possibilidade de trabalhar junto a uma câmera.

O apontador laser é utilizado como referência visual/óptica. Associado à câmera e ao processamento no Raspberry Pi, pode apoiar experimentos de scanning e percepção ativa.

## Revisões

O diretório contém peças de diferentes revisões.

Antes de imprimir:

1. confirme o nome e a revisão da peça;
2. valide a escala do STL;
3. verifique pontos de fixação;
4. confirme compatibilidade com servos e placas instalados;
5. confira a montagem completa antes de fabricar várias unidades.

## Próxima evolução documental

Uma revisão futura deve identificar claramente:

- conjunto mecânico de referência;
- lista completa das peças;
- quantidade necessária de cada peça;
- orientação de impressão;
- material recomendado;
- parafusos e elementos de fixação;
- sequência de montagem.

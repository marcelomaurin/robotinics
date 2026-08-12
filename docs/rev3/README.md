# Robotinics Rev. 3

Terceira edição revista e ampliada do livro Robotinics, por Marcelo Maurin Martins.

## Arquivos

- `Robotinics_Rev3.pdf`: edição final em português para leitura e distribuição;
- `Robotinics_Rev3.docx`: edição final editável em português;
- `manuscrito_rev3.md`: fonte textual principal em português;
- `Robotinics_Rev3_EN.pdf`: edição final em inglês para leitura e distribuição;
- `Robotinics_Rev3_EN.docx`: edição final editável em inglês;
- `manuscript_rev3_en.md`: fonte textual principal em inglês;
- `build_rev3.py`: gerador bilíngue do DOCX e dos diagramas técnicos;
- `assets/`: imagens CAD preservadas do acervo Robotinics.

## Referências congeladas

- Robotinics: `61d2a19d10e6701e27e46181e1a6c740b8ee4e30`;
- TCHATGPT: `15d5e1a7780088701716896cfe9fb3afe0e7b71a`.

## Reconstrução

Requer Python 3, `python-docx`, `Pillow` e `pypdf`.

```bash
python3 build_rev3.py build --output Robotinics_Rev3.docx
```

Para reconstruir a edição inglesa, selecione seu manuscrito. O idioma também
pode ser informado explicitamente com `--language en-US`, mas normalmente é
lido dos metadados do próprio arquivo.

```bash
python3 build_rev3.py --manuscript manuscript_rev3_en.md \
  build --output Robotinics_Rev3_EN.docx
```

Para gerar o PDF, abra o DOCX em um editor compatível ou use o LibreOffice em modo headless. O sumário final utiliza uma segunda passagem: renderize uma primeira prova em PDF, extraia o mapa de páginas e reconstrua o DOCX.

```bash
python3 build_rev3.py map --pdf Robotinics_Rev3.pdf --output page_map.json
python3 build_rev3.py build --output Robotinics_Rev3.docx --page-map page_map.json
```

Na edição inglesa:

```bash
python3 build_rev3.py --manuscript manuscript_rev3_en.md \
  map --pdf Robotinics_Rev3_EN.pdf --output page_map_en.json
python3 build_rev3.py --manuscript manuscript_rev3_en.md \
  build --output Robotinics_Rev3_EN.docx --page-map page_map_en.json
```

## Conteúdo da revisão

A Rev. 3 corrige cálculos e instruções técnicas da edição anterior e acrescenta uma arquitetura de IA supervisionada baseada no TCHATGPT. O Arduino mantém o controle determinístico; o Raspberry Pi coordena serviços; comandos produzidos pela IA passam por catálogo, validação, confirmação, limites locais e watchdog antes de alcançar atuadores.

O livro também apresenta voz, visão computacional, memória, RAG, observabilidade, plano de testes, protocolo de comandos e uma matriz detalhada de correções.

## Segurança e licença

O projeto é educacional e experimental. Baterias de íons de lítio, ferramentas, soldagem, motores e partes móveis exigem proteção, supervisão e componentes adequados.

O snapshot examinado do Robotinics não contém uma licença formal. A publicação ou redistribuição deve ser acompanhada pela licença escolhida pelo autor.

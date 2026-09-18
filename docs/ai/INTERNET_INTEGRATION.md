# Integração do Robotinics com a Internet

## Objetivo

Permitir que o Raspberry Pi consulte a internet para complementar respostas e diagnóstico sem transformar conteúdo externo em comando de hardware.

## Arquitetura

```text
TAIAgent
   |
   v
InternetTool
   |
   +-- Search Adapter
   +-- HTTP/API Adapter
   +-- Chromium Adapter
   |
   v
Content Extractor
   |
   v
Source Cache
   |
   v
Context Builder
   |
   v
TCHATGPT
```

## Formas de acesso

### APIs HTTP

Preferidas quando existe serviço estruturado.

Exemplos:

- documentação técnica;
- meteorologia;
- APIs públicas;
- serviços internos.

### Busca web

Um adaptador de busca retorna URLs e metadados. A busca deve ser uma ferramenta separada do LLM.

### Navegação

`TAIChromiumBrowser` pode ser utilizado para páginas que exigem navegação ou renderização, desde que CEF esteja validado no Raspberry escolhido.

Como Chromium/CEF pode ser pesado em ARM, HTTP simples deve ser preferido quando suficiente.

## Contrato do InternetTool

Entrada sugerida:

```text
query
max_results
allowed_domains
timeout
max_bytes
purpose
```

Saída sugerida:

```json
{
  "query": "manual do componente",
  "retrieved_at": "ISO-8601",
  "sources": [
    {
      "url": "https://...",
      "title": "...",
      "summary": "..."
    }
  ]
}
```

## Cache

Resultados devem ter TTL de acordo com a natureza da informação.

Exemplos:

- datasheet: dias;
- documentação web: horas;
- notícia: minutos;
- clima: minutos.

## Internet + RAG

Conteúdo web útil pode ser colocado em índice temporário:

```text
web -> sanitize -> chunk -> temporary RAG -> answer
```

Esse índice deve registrar origem e expirar.

## Regras de segurança

Não executar automaticamente:

- scripts encontrados em páginas;
- comandos shell sugeridos por conteúdo externo;
- firmware baixado da internet;
- alterações de configuração;
- comandos do robô extraídos diretamente de uma página.

## Falhas

Se internet estiver indisponível:

- informar a limitação;
- usar documentação local quando possível;
- não inventar conteúdo ausente;
- não bloquear controle local.

## Credenciais

Tokens ficam fora do Git:

```text
ROBOTINICS_LLM_TOKEN
ROBOTINICS_SEARCH_TOKEN
ROBOTINICS_LLM_URL
ROBOTINICS_SEARCH_URL
```

Use variáveis de ambiente ou arquivo protegido fora do repositório.

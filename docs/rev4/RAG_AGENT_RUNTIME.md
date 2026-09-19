# RAG e Agent Runtime — Rev. 4

## RAG local

A recuperação documental deixou de usar apenas presença simples de palavras.

O ranking atual combina:

- frequência de termos;
- comprimento do documento;
- frequência documental;
- peso BM25-like;
- boost para ocorrência no título;
- boost para ocorrência no caminho;
- metadados por documento.

Cada trecho entregue ao LLM inclui metadados JSON:

```json
{
  "path": "...",
  "title": "...",
  "score": 1.23,
  "tokens": 420
}
```

Isso melhora rastreabilidade e permite evoluir futuramente para FTS/SQLite e embeddings sem mudar o contrato com o AI Runtime.

## Ferramentas tipadas

O Agent Runtime conhece atualmente três tipos de ferramenta:

```text
gateway.read
gateway.diagnostic
gateway.command
```

A política é aplicada fora do prompt, em `actionpolicy.pas`.

## Classificação de risco

```text
READ_ONLY
DIAGNOSTIC
PHYSICAL_LOW
PHYSICAL_HIGH
FORBIDDEN
```

Leituras e diagnósticos não exigem confirmação.

`PARA` é permitido sem confirmação porque reduz risco físico.

Comandos de movimento e atuadores exigem confirmação humana explícita antes de execução.

Comandos não catalogados são negados.

## Limite atual

A política já está implementada como unidade tipada e integrada ao prompt do AI Runtime, mas o runtime ainda não executa autonomamente ações físicas. Isso é intencional: a próxima evolução deve criar um executor de ferramentas que consulte a política, solicite confirmação quando necessário e então use exclusivamente o Gateway.

## Próximos passos

- índice FTS persistente;
- embeddings opcionais;
- busca híbrida lexical + semântica;
- executor de ferramentas;
- confirmação humana persistida na tarefa;
- correlação de evidências entre tool call, Gateway e resultado observado.

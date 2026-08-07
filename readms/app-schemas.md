# backend/app/schemas.py

**Localização:** `/backend/app/schemas.py`

## O que faz

Define os schemas Pydantic usados para validação de entrada e serialização de saída da API. Separa a camada HTTP do modelo de banco de dados.

## Classes definidas

### `ReadingStatus` (StrEnum)
Enum com os 3 valores válidos de status de leitura:
- `QUERO_LER`
- `LENDO`
- `LIDO`

### `BookFields` (base compartilhada)
Campos comuns a criação e edição. Aplica validações:
- `title`: 1–160 chars
- `author`: 1–120 chars
- `isbn`: opcional, máx. 20 chars — string vazia vira `None`
- `category`: 1–80 chars, padrão `"Geral"`
- `reading_status`: padrão `QUERO_LER`
- `rating`: opcional, 1–5
- `notes`: opcional, máx. 2000 chars — string vazia vira `None`

### `BookCreate`
Herda `BookFields`. Usado no `POST /api/books`.

### `BookReplace`
Herda `BookFields`. Usado no `PUT /api/books/{id}` (substituição completa).

### `BookStatusUpdate`
Apenas `reading_status`. Usado no `PATCH /api/books/{id}/status`.

### `BookResponse`
Herda `BookFields` + adiciona `id`, `created_at`, `updated_at`. Retornado em todas as respostas com dados de livro. Tem `from_attributes=True` para serializar direto do ORM.

### `HealthResponse`
Campos `status` e `database`. Retornado pelo `GET /api/health`.

## Dependências

- `app/__init__.py`
- Lib: `pydantic >= 2.0`

## Quem usa este arquivo

- `app/main.py` → importa todos os schemas para tipagem das rotas

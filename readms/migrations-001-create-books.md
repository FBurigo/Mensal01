# backend/migrations/versions/001_create_books.py

**Localização:** `/backend/migrations/versions/001_create_books.py`

## O que faz

Primeira (e única) migration do projeto. Cria a tabela `books` no banco de dados com todas as colunas, índices e constraints necessários.

## Revision ID: `001`

Não tem `down_revision` (é a migration inicial/raiz).

## O que `upgrade()` cria

- Tabela `books` com as colunas: `id`, `title`, `author`, `isbn`, `category`, `reading_status`, `rating`, `notes`, `created_at`, `updated_at`
- Índices: `ix_books_title`, `ix_books_author`, `ix_books_reading_status`
- Constraint única: `uq_books_isbn`
- Constraints de check: `ck_books_reading_status` e `ck_books_rating`

## O que `downgrade()` faz

Remove os índices e a tabela `books` completamente.

## Dependências

- `migrations/env.py` → executa esta migration
- `app/models.py` → deve estar em sincronia com o que esta migration cria
- Libs: `alembic`, `sqlalchemy`

## Como aplicar

```bash
cd backend
alembic upgrade head
# ou automaticamente ao subir o container Docker
```

# backend/app/models.py

**Localização:** `/backend/app/models.py`

## O que faz

Define o modelo ORM da tabela `books` usando SQLAlchemy Declarative. Este arquivo é a "fonte de verdade" do esquema do banco de dados.

## Modelo: `Book`

Tabela: `books`

| Coluna | Tipo | Restrições |
|---|---|---|
| `id` | INTEGER | PK, autoincrement |
| `title` | VARCHAR(160) | NOT NULL, index |
| `author` | VARCHAR(120) | NOT NULL, index |
| `isbn` | VARCHAR(20) | UNIQUE, nullable |
| `category` | VARCHAR(80) | NOT NULL, default `"Geral"` |
| `reading_status` | VARCHAR(20) | NOT NULL, index |
| `rating` | INTEGER | nullable |
| `notes` | TEXT | nullable |
| `created_at` | DATETIME(tz) | server default `now()` |
| `updated_at` | DATETIME(tz) | server default `now()`, atualiza no update |

## Constraints de banco

- `ck_books_reading_status`: `reading_status` deve ser `'QUERO_LER'`, `'LENDO'` ou `'LIDO'`
- `ck_books_rating`: `rating` deve ser `NULL` ou entre `1` e `5`
- `uq_books_isbn`: ISBN único (aplicado na migration)

## Dependências

- `app/__init__.py`
- Lib: `SQLAlchemy >= 2.0`

## Quem usa este arquivo

- `app/main.py` → importa `Book` para queries
- `migrations/env.py` → importa `Base.metadata` para autogenerate de migrations
- `migrations/versions/001_create_books.py` → cria a tabela fisicamente
- `tests/test_books.py` → usa `Base.metadata` para criar tabelas em SQLite em memória

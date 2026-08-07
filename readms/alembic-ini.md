# backend/alembic.ini

**Localização:** `/backend/alembic.ini`

## O que faz

Arquivo de configuração do Alembic (ferramenta de migrations de banco de dados). Define onde ficam os scripts de migration e como o Alembic deve se conectar ao banco.

## Configurações principais

| Chave | Valor | Descrição |
|---|---|---|
| `script_location` | `migrations` | Pasta onde ficam os scripts de migration |
| `prepend_sys_path` | `.` | Adiciona o diretório atual ao `sys.path` do Python (necessário para importar `app.database`) |

## Como a URL do banco é definida

A URL **não** está hardcoded aqui. Ela é injetada programaticamente pelo `migrations/env.py`, que lê de `app/database.py` (que por sua vez lê variáveis de ambiente).

## Dependências

- `backend/migrations/env.py` — lê este arquivo na inicialização
- `backend/migrations/` — pasta referenciada por `script_location`
- Variáveis de ambiente do banco (via `app/database.py`)

## Como usar

```bash
cd backend

# Aplicar todas as migrations pendentes
alembic upgrade head

# Ver o histórico de migrations
alembic history

# Gerar nova migration automaticamente
alembic revision --autogenerate -m "descricao"

# Reverter última migration
alembic downgrade -1
```

# backend/app/database.py

**Localização:** `/backend/app/database.py`

## O que faz

Configura a conexão com o banco de dados MySQL usando SQLAlchemy. Fornece:

- **`DATABASE_URL`**: a URL de conexão, montada a partir de variáveis de ambiente
- **`engine`**: o motor de conexão SQLAlchemy (com `pool_pre_ping=True` para reconectar automaticamente)
- **`SessionLocal`**: fábrica de sessões do banco
- **`get_db()`**: gerador usado como dependência do FastAPI — abre uma sessão, entrega para a rota, e fecha ao final

## Variáveis de ambiente lidas

| Variável | Padrão | Descrição |
|---|---|---|
| `DATABASE_URL` | *(monta abaixo)* | URL completa — se definida, ignora as demais |
| `DB_USER` | `biblioteca_app` | Usuário do MySQL |
| `DB_PASSWORD` | `biblioteca` | Senha do MySQL |
| `DB_HOST` | `localhost` | Host do MySQL |
| `DB_PORT` | `3306` | Porta do MySQL |
| `DB_NAME` | `biblioteca` | Nome do banco |

## Driver usado

`mysql+pymysql` (PyMySQL puro Python, sem dependência de cliente MySQL nativo)

## Dependências

- `app/__init__.py` (pacote Python)
- Variáveis de ambiente do MySQL definidas em `.env` / Docker Compose
- Lib: `SQLAlchemy`, `PyMySQL` (ver `requirements.txt`)

## Quem usa este arquivo

- `app/main.py` → injeta `get_db` nas rotas via `Depends`
- `migrations/env.py` → lê `DATABASE_URL` para rodar migrations

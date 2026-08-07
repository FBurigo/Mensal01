# backend/migrations/env.py

**Localização:** `/backend/migrations/env.py`

## O que faz

Script de ambiente do Alembic. É executado automaticamente toda vez que um comando `alembic` é rodado. Ele conecta o Alembic ao banco de dados do projeto e ao modelo ORM para detecção automática de mudanças no schema.

## O que configura

- Lê a `DATABASE_URL` de `app/database.py` e a injeta na configuração do Alembic
- Define `target_metadata = Base.metadata` para que o Alembic possa comparar o estado atual do banco com os modelos e gerar migrations automáticas
- Suporta dois modos de execução:
  - **offline**: gera SQL sem conectar ao banco
  - **online**: conecta ao banco e aplica as migrations

## Dependências

- `app/database.py` → `DATABASE_URL`
- `app/models.py` → `Base` (metadados do ORM)
- `backend/alembic.ini` → lido pelo `context.config`
- Libs: `alembic`, `sqlalchemy`

## Quem executa este arquivo

- O CLI do Alembic (`alembic upgrade head`, `alembic revision`, etc.)
- O `backend/Dockerfile` na inicialização do container

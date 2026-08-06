# WORKFLOW — Dependências e ordem de execução

Este documento mostra o que cada parte do projeto precisa para funcionar e a ordem correta para rodar tudo.

---

## Visão geral da arquitetura

```
Usuário (Navegador)
        │  HTTP :80
        ▼
┌─────────────────┐
│   FRONTEND      │  nginx:1.27-alpine
│  index.html     │  Serve HTML/CSS/JS
│  app.js         │  Proxy /api/ → backend
│  styles.css     │
└────────┬────────┘
         │  HTTP interno :8000  (rede Docker: edge)
         ▼
┌─────────────────┐
│   BACKEND       │  python:3.13-slim
│  app/main.py    │  FastAPI + Uvicorn
│  app/models.py  │  ORM SQLAlchemy
│  app/schemas.py │  Validação Pydantic
│  app/database.py│  Conexão MySQL
└────────┬────────┘
         │  MySQL :3306  (rede Docker: data — isolada)
         ▼
┌─────────────────┐
│   DATABASE      │  mysql:8.4
│  tabela: books  │  Volume: mysql_data
└─────────────────┘
```

---

## Ordem de inicialização (Docker Compose)

```
1. database      → sobe o MySQL e aguarda healthcheck
        │
        │ (condition: service_healthy)
        ▼
2. backend       → instala deps, roda migrations, sobe Uvicorn
        │
        │ (condition: service_healthy)
        ▼
3. frontend      → sobe Nginx servindo os arquivos estáticos
```

---

## Dependências por arquivo

### Para rodar o projeto completo (via Docker)

```
.env.example ──► .env  (copiar e preencher senhas)
        │
        ▼
compose.yaml
├── database  ◄── variáveis MYSQL_* do .env
├── backend   ◄── backend/Dockerfile
│               ├── requirements.txt       (fastapi, uvicorn, sqlalchemy, pymysql, alembic)
│               ├── alembic.ini            ──► migrations/env.py
│               │                                  ├── app/database.py  (DATABASE_URL)
│               │                                  └── app/models.py    (Base.metadata)
│               ├── migrations/versions/
│               │   └── 001_create_books.py  (cria tabela books)
│               └── app/
│                   ├── __init__.py
│                   ├── database.py
│                   ├── models.py
│                   ├── schemas.py
│                   └── main.py
└── frontend  ◄── frontend/Dockerfile
                ├── nginx.conf
                └── src/
                    ├── index.html
                    ├── app.js
                    └── styles.css
```

---

## Para rodar apenas os testes (sem Docker)

```
Python 3.13+
        │
        ▼
pip install -r backend/requirements-dev.txt
        │  inclui: requirements.txt + pytest + httpx
        │
        ▼
pytest backend/tests/test_books.py
        │
        ├── app/main.py        (API FastAPI testada)
        ├── app/models.py      (Base para criar tabelas em memória)
        ├── app/database.py    (get_db sobrescrito pelo teste)
        └── app/schemas.py     (schemas de validação)
        
⚠ Usa SQLite em memória — não precisa de MySQL nem Docker
```

---

## Para gerar uma nova migration

```
cd backend
alembic revision --autogenerate -m "descricao"
        │
        ├── Lê: alembic.ini         (localização dos scripts)
        ├── Lê: migrations/env.py   (conecta ao banco e carrega metadados)
        │         ├── app/database.py  (DATABASE_URL)
        │         └── app/models.py    (Base.metadata — detecta mudanças)
        └── Usa: migrations/script.py.mako  (template da migration gerada)
        
Gera: migrations/versions/00X_<descricao>.py
```

---

## Resumo: o que você precisa em cada cenário

| Objetivo | Pré-requisitos |
|---|---|
| Rodar tudo em produção/desenvolvimento | Docker + `.env` preenchido |
| Rodar testes unitários | Python 3.13 + `requirements-dev.txt` |
| Rodar o backend local sem Docker | Python + `requirements.txt` + MySQL acessível + variáveis de ambiente |
| Gerar nova migration | Python + `requirements.txt` + banco acessível |
| Alterar a UI | Editar `src/index.html`, `app.js` ou `styles.css` e rebuildar o container frontend |
| Adicionar endpoint à API | Editar `app/main.py` (e possivelmente `app/schemas.py`) e rebuildar o backend |
| Alterar o schema do banco | Editar `app/models.py` → gerar migration → aplicar com `alembic upgrade head` |

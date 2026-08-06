# backend/requirements.txt

**Localização:** `/backend/requirements.txt`

## O que faz

Lista as dependências Python de produção do backend. Instalado dentro da imagem Docker pelo `Dockerfile`.

## Dependências

| Pacote | Versão | Para que serve |
|---|---|---|
| `fastapi` | `>=0.115, <1.0` | Framework web / roteamento HTTP |
| `uvicorn[standard]` | `>=0.34, <1.0` | Servidor ASGI para rodar o FastAPI |
| `SQLAlchemy` | `>=2.0, <3.0` | ORM e conexão com o banco de dados |
| `PyMySQL` | `>=1.1, <2.0` | Driver Python puro para MySQL |
| `alembic` | `>=1.14, <2.0` | Migrations de banco de dados |

## Como instalar

```bash
cd backend
pip install -r requirements.txt
```

## Quem usa este arquivo

- `backend/Dockerfile` → `RUN pip install -r requirements.txt`
- `backend/requirements-dev.txt` → inclui este via `-r requirements.txt`

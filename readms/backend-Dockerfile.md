# backend/Dockerfile

**Localização:** `/backend/Dockerfile`

## O que faz

Define a imagem Docker do backend Python/FastAPI. Ao ser construída, cria um container que:

1. Instala as dependências Python do `requirements.txt`
2. Copia o código do app e as migrations Alembic
3. Na inicialização, executa as migrations (`alembic upgrade head`) e sobe o servidor FastAPI com Uvicorn na porta 8000

## Detalhes técnicos

| Item | Valor |
|---|---|
| Imagem base | `python:3.13-slim` |
| Porta exposta | `8000` |
| Usuário | `app` (não-root, por segurança) |
| Comando de start | `alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 1` |

## Arquivos copiados para dentro da imagem

- `requirements.txt`
- `alembic.ini`
- `migrations/` (pasta inteira)
- `app/` (pasta inteira)

## Dependências para construir

- `backend/requirements.txt` — precisa existir antes do build
- `backend/alembic.ini`
- `backend/migrations/`
- `backend/app/`

## Como buildar manualmente

```bash
cd backend
docker build -t biblioteca-backend .
```

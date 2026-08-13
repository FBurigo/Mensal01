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
| Rótulos OCI | `title`, `description`, `source` e `revision` (SHA do commit) |

## Arquivos copiados para dentro da imagem

- `requirements.txt`
- `alembic.ini`
- `migrations/` (pasta inteira)
- `app/` (pasta inteira)

## Identificação da versão

```dockerfile
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
```

O pipeline informa o SHA do commit (`--build-arg APP_VERSION=$GITHUB_SHA`), que
fica gravado de três formas: na tag da imagem no GHCR, no rótulo
`org.opencontainers.image.revision` e na variável `APP_VERSION` lida por
`app/main.py` e devolvida em `/api/version`. Em build local sem argumento, a
imagem se identifica como `dev`.

## Dependências para construir

- `backend/requirements.txt` — precisa existir antes do build
- `backend/alembic.ini`
- `backend/migrations/`
- `backend/app/`

## Como buildar manualmente

```bash
cd backend
docker build -t biblioteca-backend --build-arg APP_VERSION="$(git rev-parse HEAD)" .
```

## Como verificar a imagem

```bash
./scripts/smoke-backend.sh biblioteca-backend "$(git rev-parse HEAD)"
```

O script sobe a imagem sem banco (substituindo o comando padrão por apenas o
Uvicorn, já que `/api/version` não consulta o MySQL) e confere que endpoint,
rótulo OCI e variável de ambiente apontam para o mesmo commit.

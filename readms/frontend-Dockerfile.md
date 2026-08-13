# frontend/Dockerfile

**Localização:** `/frontend/Dockerfile`

## O que faz

Define a imagem Docker do frontend. Usa Nginx para servir os arquivos estáticos
(HTML, CSS, JS) e fazer proxy reverso das chamadas `/api/` para o backend.

## Detalhes técnicos

| Item | Valor |
|---|---|
| Imagem base | `nginx:1.27-alpine` |
| Porta exposta | `80` |
| Template do Nginx | `/etc/nginx/templates/default.conf.template` |
| Trecho de cabeçalhos | `/etc/nginx/snippets/security-headers.conf` |
| Arquivos servidos | `/usr/share/nginx/html` |
| Healthcheck | `wget --spider http://127.0.0.1/healthz` |

## O que é copiado

- `nginx.conf.template` → configuração do servidor e do proxy para o backend
- `security-headers.conf` → cabeçalhos de segurança usados por cada `location`
- `src/` (pasta inteira) → `index.html`, `app.js`, `styles.css`

## Identificação da versão

```dockerfile
ARG APP_VERSION=dev
RUN printf '{"version":"%s"}\n' "${APP_VERSION}" > /usr/share/nginx/html/version.json
```

O pipeline informa o SHA do commit (`--build-arg APP_VERSION=$GITHUB_SHA`), que
fica gravado de três formas: no rótulo `org.opencontainers.image.revision`, na
tag da imagem no GHCR e em `/version.json`, consultado pelo rodapé da página.
Em build local sem argumento, a imagem se identifica como `dev`.

## Variáveis de ambiente

| Variável | Padrão | Para que serve |
|---|---|---|
| `BACKEND_HOST` | `backend` | nome ou IP do backend usado pelo proxy |
| `BACKEND_PORT` | `8000` | porta do backend |
| `NGINX_RESOLVER` | `127.0.0.11` | DNS interno do Docker |
| `NGINX_ENVSUBST_FILTER` | regex das três acima | impede que variáveis do Nginx sejam substituídas |

## Dependências para construir

- `frontend/nginx.conf.template` — configuração do servidor
- `frontend/security-headers.conf` — cabeçalhos de segurança
- `frontend/src/index.html` — página principal
- `frontend/src/app.js` — lógica da interface
- `frontend/src/styles.css` — estilos

O `.dockerignore` funciona como lista de permissão: ignora tudo e libera apenas
esses arquivos, para que nenhum `.env`, chave ou dump criado depois entre na
imagem por esquecimento.

## Como buildar manualmente

```bash
cd frontend
docker build -t biblioteca-frontend --build-arg APP_VERSION="$(git rev-parse HEAD)" .
```

## Como verificar a imagem

```bash
./scripts/smoke-frontend.sh biblioteca-frontend "$(git rev-parse HEAD)"
```

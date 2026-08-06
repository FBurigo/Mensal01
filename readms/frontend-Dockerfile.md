# frontend/Dockerfile

**Localização:** `/frontend/Dockerfile`

## O que faz

Define a imagem Docker do frontend. Usa Nginx para servir os arquivos estáticos (HTML, CSS, JS) e fazer proxy reverso das chamadas `/api/` para o backend.

## Detalhes técnicos

| Item | Valor |
|---|---|
| Imagem base | `nginx:1.27-alpine` |
| Porta exposta | `80` |
| Config do Nginx | `/etc/nginx/conf.d/default.conf` |
| Arquivos servidos | `/usr/share/nginx/html` |

## O que é copiado

- `nginx.conf` → configura o servidor e o proxy para o backend
- `src/` (pasta inteira) → os arquivos estáticos: `index.html`, `app.js`, `styles.css`

## Dependências para construir

- `frontend/nginx.conf` — configuração do servidor
- `frontend/src/index.html` — página principal
- `frontend/src/app.js` — lógica da interface
- `frontend/src/styles.css` — estilos

## Como buildar manualmente

```bash
cd frontend
docker build -t biblioteca-frontend .
```

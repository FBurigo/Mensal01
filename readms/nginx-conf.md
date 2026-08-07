# frontend/nginx.conf

**Localização:** `/frontend/nginx.conf`

## O que faz

Configuração do servidor Nginx dentro do container do frontend. Tem duas responsabilidades principais:

1. **Servir os arquivos estáticos** (HTML, CSS, JS) da aplicação
2. **Fazer proxy reverso** das chamadas de API para o backend

## Regras de roteamento

| Rota | Comportamento |
|---|---|
| `/api/` | Proxy para `http://backend:8000/api/` (container backend na rede Docker) |
| `/` e demais | Serve `index.html` (SPA fallback) |
| `*.css`, `*.js`, `*.svg`, imagens | Cache de 1 hora (`Cache-Control: public, max-age=3600`) |

## Headers de segurança aplicados

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Content-Security-Policy`: restringe carregamento apenas de fontes próprias (`'self'`)

## Por que o proxy é necessário

O frontend é uma SPA (Single Page Application) pura — o navegador faz chamadas para `/api/books` que chegam ao Nginx, que as repassa para o backend. Assim, o usuário acessa tudo pelo mesmo host/porta e não há problema de CORS.

## Dependências

- Container `backend` rodando e acessível pela rede Docker interna com o hostname `backend`
- `frontend/Dockerfile` — copia este arquivo para dentro da imagem

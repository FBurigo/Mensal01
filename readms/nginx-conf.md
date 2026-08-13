# frontend/nginx.conf.template

**Localização:** `/frontend/nginx.conf.template`
(antes `frontend/nginx.conf` — o arquivo passou a ser um template)

## O que faz

Configuração do servidor Nginx dentro do container do frontend. Tem duas
responsabilidades principais:

1. **Servir os arquivos estáticos** (HTML, CSS, JS) da aplicação
2. **Fazer proxy reverso** das chamadas de API para o backend

## Por que é um template

A imagem oficial do Nginx aplica `envsubst` nos arquivos de
`/etc/nginx/templates` e grava o resultado em `/etc/nginx/conf.d/default.conf`
antes de iniciar o servidor. Assim, três valores podem mudar sem reconstruir a
imagem:

| Variável | Padrão | Para que serve |
|---|---|---|
| `BACKEND_HOST` | `backend` | nome ou IP do backend |
| `BACKEND_PORT` | `8000` | porta do backend |
| `NGINX_RESOLVER` | `127.0.0.11` | DNS interno do Docker em redes do Compose |

O `NGINX_ENVSUBST_FILTER` definido no Dockerfile garante que apenas essas três
sejam substituídas — as variáveis do próprio Nginx (`$host`, `$request_uri`,
`$remote_addr`) permanecem intactas.

## Regras de roteamento

| Rota | Comportamento |
|---|---|
| `/healthz` | responde `ok` local, sem consultar o backend (usado no healthcheck) |
| `/version.json` | versão da imagem do frontend, sem cache |
| `/api/docs` | proxy para o backend com CSP própria (o Swagger UI usa CDN) |
| `/api/` | proxy para `http://$backend_upstream$request_uri` |
| `/` e demais | serve `index.html` (fallback de SPA) |
| `*.css`, `*.js`, `*.svg`, imagens | cache de 1 hora (`Cache-Control: public, max-age=3600`) |

Detalhes que evitam problemas conhecidos:

- **`^~` no bloco `/api/`** dá prioridade sobre a regra de cache de estáticos,
  que é uma expressão regular e seria avaliada antes de um prefixo comum.
- **`$request_uri` no `proxy_pass`** preserva caminho e query string
  (`/api/books?q=hobbit&reading_status=LENDO` chega inteiro ao backend).
- **Sem `expires`** no bloco de estáticos: a diretiva emitiria um segundo
  `Cache-Control`, duplicando o cabeçalho.

## Resolução do backend em tempo de requisição

```nginx
resolver ${NGINX_RESOLVER} valid=10s ipv6=off;
resolver_timeout 3s;
set $backend_upstream "${BACKEND_HOST}:${BACKEND_PORT}";
```

Escrever `proxy_pass http://backend:8000/...` faz o Nginx resolver o nome **na
inicialização** e recusar-se a subir quando o container do backend ainda não
existe (`host not found in upstream`). Usando uma variável mais um `resolver`,
o nome é resolvido a cada requisição: a imagem do frontend inicia sozinha — o
que é necessário para conferir a imagem publicada no GHCR — e, sem backend,
apenas as chamadas `/api` respondem 502/504.

## Headers de segurança aplicados

Ficam em `frontend/security-headers.conf`, incluído por cada `location`:

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Content-Security-Policy`: restringe carregamento apenas de fontes próprias (`'self'`)

A repetição é necessária: no Nginx, um `add_header` dentro de um `location`
cancela os cabeçalhos herdados do nível `server`. Sem o trecho incluído, CSS e
JS (que definem `Cache-Control`) sairiam sem `nosniff` e sem CSP.

## Por que o proxy é necessário

O frontend é uma SPA (Single Page Application) pura — o navegador faz chamadas
para `/api/books` que chegam ao Nginx, que as repassa para o backend. Assim, o
usuário acessa tudo pelo mesmo host/porta e não há problema de CORS.

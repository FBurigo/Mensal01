# Evidências — Build e publicação das imagens Docker

Referência: [docs/CARTAO-IMAGENS-DOCKER.md](CARTAO-IMAGENS-DOCKER.md).

| Responsável | Escopo |
|---|---|
| Eduardo | build e publicação da imagem do frontend; Nginx e proxy `/api`; verificar se a imagem publicada pode ser baixada e iniciada |
| Felipe Burigo | identificação da versão (`APP_VERSION`, `/api/version`); build e publicação da imagem do backend; verificar a associação entre imagem e commit |

## Como a versão chega até a aplicação

```text
commit na main
   └── github.sha
        ├── tag da imagem      ghcr.io/fburigo/mensal01-<serviço>:<sha>
        ├── rótulo OCI         org.opencontainers.image.revision=<sha>
        ├── backend            ARG/ENV APP_VERSION → /api/version
        └── frontend           ARG APP_VERSION → /version.json → rodapé da página
```

Os quatro caminhos precisam concordar. É isso que os scripts de verificação
conferem, tanto na imagem construída no Pull Request quanto na imagem já
publicada no GHCR.

## Problema encontrado e corrigido (frontend)

A configuração anterior do Nginx apontava direto para o nome do container:

```nginx
proxy_pass http://backend:8000/api/;
```

Nomes escritos assim são resolvidos **quando o Nginx inicia**. Se o container
do backend não existir naquele momento, o processo nem sobe:

```text
$ nginx -t
nginx: [emerg] host not found in upstream "backend" in .../default.conf:15
nginx: configuration file ... test failed
```

Na prática, isso quebraria o critério "as imagens podem ser baixadas pela VM":
ao baixar a imagem do frontend e rodá-la sozinha para conferir, o container
morre na inicialização, mesmo estando correta.

A correção mantém o comportamento em produção e resolve o nome **a cada
requisição**, com um resolvedor DNS declarado:

```nginx
resolver ${NGINX_RESOLVER} valid=10s ipv6=off;
resolver_timeout 3s;
set $backend_upstream "${BACKEND_HOST}:${BACKEND_PORT}";
...
proxy_pass http://$backend_upstream$request_uri;
```

Sem o backend, o site continua no ar e apenas as chamadas `/api` respondem
502/504 em cerca de três segundos.

## Alterações

### Frontend e pipeline (Eduardo)

| Arquivo | O que mudou e por quê |
|---|---|
| `frontend/nginx.conf` → `frontend/nginx.conf.template` | virou template (`envsubst` da imagem oficial do Nginx); resolução do backend em tempo de requisição; `/healthz` local; `/version.json` sem cache; `^~ /api/` para a API nunca cair na regra de cache de estáticos; `$request_uri` preservando caminho e query string |
| `frontend/security-headers.conf` | novo. Cabeçalhos de segurança em um trecho incluído por cada `location`: no Nginx, um `add_header` dentro do bloco cancela os herdados, e por isso CSS e JS saíam sem `nosniff` e sem CSP |
| `frontend/Dockerfile` | `ARG APP_VERSION`, rótulos OCI (`revision` = SHA), `/version.json` gravado no build, `HEALTHCHECK`, variáveis `BACKEND_HOST` / `BACKEND_PORT` / `NGINX_RESOLVER` |
| `frontend/.dockerignore` | passou a ser lista de permissão: ignora tudo e libera só `src/` e as configurações, de modo que nenhum `.env`, chave ou dump criado depois entre na imagem por esquecimento |
| `frontend/src/index.html`, `app.js`, `styles.css` | rodapé mostra a versão da interface (`/version.json`) e a do backend (`/api/version`) |
| `scripts/smoke-frontend.sh` | verificação da imagem do frontend (inicia sozinha, estáticos, versão, cabeçalhos, proxy `/api`, ausência de segredos) |
| `.gitattributes` | novo. Mantém `*.sh` com LF mesmo em checkout no Windows (com CRLF o bash falha com "bad interpreter") |

### Backend e identificação da versão (Felipe)

| Arquivo | O que mudou e por quê |
|---|---|
| `backend/app/main.py` | `APP_VERSION` lida do ambiente e endpoint `GET /api/version` (já no repositório) |
| `backend/app/schemas.py` | `VersionResponse` (já no repositório) |
| `backend/tests/test_books.py` | teste do endpoint de versão (já no repositório) |
| `backend/Dockerfile` | `ARG`/`ENV APP_VERSION` (já no repositório) mais os rótulos OCI, com `revision` apontando para o commit |
| `scripts/smoke-backend.sh` | novo. Sobe a imagem do backend e confere que `/api/version`, o rótulo OCI e a variável `APP_VERSION` apontam para o mesmo SHA; confere ainda usuário não-root e ausência de segredos e de banco local na imagem |
| `backend/.dockerignore` | passou a ser lista de permissão: ignora tudo e libera só `app/`, `migrations/`, `alembic.ini` e `requirements.txt`, impedindo que `.env`, `biblioteca_dev.db` ou uma chave entrem na imagem |

### Comum aos dois

| Arquivo | O que mudou e por quê |
|---|---|
| `.github/workflows/ci-cd.yml` | `APP_VERSION` nos dois builds; jobs `backend-smoke` e `frontend-smoke` antes de publicar; job `verificar-publicacao` que baixa e inicia as duas imagens depois do merge |
| `scripts/verificar-imagem-publicada.sh` | novo. Baixa as duas imagens do GHCR, inicia as duas e confere que tag, rótulo, `/api/version` e `/version.json` correspondem ao commit |
| `compose.yaml` | build de backend e frontend recebe `APP_VERSION`; healthcheck do frontend passou a usar `/healthz` |
| `README.md`, `readms/*` | documentação das imagens, da versão implantada e dos scripts |

## Ordem de execução do pipeline

```text
test (pytest)
  ├── backend-smoke   → build da imagem do backend + scripts/smoke-backend.sh
  └── frontend-smoke  → build da imagem do frontend + scripts/smoke-frontend.sh
        └── build-and-push (matriz backend + frontend)
              push só quando event_name == push e ref == refs/heads/main
              └── verificar-publicacao (só na main)
                    → scripts/verificar-imagem-publicada.sh
```

## Como o pipeline atende cada critério de aceite

| Critério | Onde é garantido |
|---|---|
| PR faz build mas não publica | `push:` do `build-push-action` é `github.event_name == 'push' && github.ref == 'refs/heads/main'` |
| Merge na `main` publica as duas imagens | job `build-and-push` com matriz `backend` + `frontend` |
| Cada imagem tem tag do SHA | `tags: ghcr.io/fburigo/<imagem>:${{ github.sha }}` e rótulo `org.opencontainers.image.revision` |
| A aplicação informa a versão | `/api/version` (backend), `/version.json` e rodapé (frontend) |
| As imagens podem ser baixadas pela VM | job `verificar-publicacao` e `scripts/verificar-imagem-publicada.sh` |
| Associação entre imagem e commit | `scripts/smoke-backend.sh` compara endpoint, rótulo e variável de ambiente |
| Nenhum segredo nos artefatos | `.dockerignore` como lista de permissão nos dois serviços, mais a conferência nos dois scripts de smoke |
| Falha nos testes impede a publicação | `build-and-push` depende de `test`, `backend-smoke` e `frontend-smoke` |

## Checklist do cartão

Implementado no código e verificado automaticamente:

- [x] Configurar Docker Buildx
- [x] Configurar autenticação no GHCR com `GITHUB_TOKEN`
- [x] Configurar permissão `packages: write`
- [x] Reutilizar o Dockerfile do backend
- [x] Reutilizar o Dockerfile do frontend
- [x] Criar a variável `APP_VERSION`
- [x] Criar o endpoint `/api/version`
- [x] Fazer `/api/version` retornar o SHA
- [x] Construir a imagem do backend
- [x] Construir a imagem do frontend
- [x] Identificar as imagens pelo SHA do commit
- [x] Impedir publicação durante Pull Requests
- [x] Publicar somente após sucesso dos testes
- [x] Garantir que `.env` e senhas não entrem nas imagens

Depende da execução real do pipeline (marcar após o merge):

- [ ] Publicar a imagem do backend no GHCR
- [ ] Publicar a imagem do frontend no GHCR
- [ ] Testar o download das imagens
- [ ] Registrar os links dos pacotes publicados

## Como reproduzir localmente

```bash
SHA="$(git rev-parse HEAD)"

# build com a mesma identificação usada pelo pipeline
docker build -t mensal01-backend:local  --build-arg APP_VERSION="$SHA" ./backend
docker build -t mensal01-frontend:local --build-arg APP_VERSION="$SHA" ./frontend

# as mesmas verificações que rodam no Pull Request
./scripts/smoke-backend.sh  mensal01-backend:local  "$SHA"
./scripts/smoke-frontend.sh mensal01-frontend:local "$SHA"

# a imagem do frontend sobe sem o backend existir
docker run --rm -p 8081:80 mensal01-frontend:local
curl -i http://localhost:8081/healthz
curl http://localhost:8081/version.json
```

Aplicação completa com a mesma versão nos dois containers:

```bash
APP_VERSION="$(git rev-parse HEAD)" docker compose up -d --build
curl http://localhost/api/version
```

Na VM, depois do merge:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u SEU_USUARIO --password-stdin
./scripts/verificar-imagem-publicada.sh <sha-do-commit>
```

## Verificações feitas antes do Pull Request

**Nginx do frontend** — configuração renderizada com `envsubst` (mesmo
procedimento da imagem oficial) e servida por um Nginx real, com um backend de
teste no lugar do FastAPI:

```text
GET /                                      200
GET /healthz                               200
GET /version.json                          {"version":"a1b2c3d4...5678"}
GET /api/version (via proxy)               {"version":"stub-backend"}
GET /api/books?q=hobbit (via proxy)        200
GET /rota-inexistente (fallback SPA)       200

URL recebida pelo backend de teste:
  "GET /api/version HTTP/1.1" 200
  "GET /api/books?q=hobbit&reading_status=LENDO HTTP/1.1" 200

Cabeçalhos em /styles.css:
  Cache-Control: public, max-age=3600
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
  Content-Security-Policy: default-src 'self'; ...
```

Cenário sem backend (host `backend` inexistente): o Nginx iniciou, `/`,
`/healthz` e `/version.json` responderam 200 e `/api/version` respondeu 502 em
3,0 s, sem derrubar o container.

**API do backend** — Uvicorn iniciado sem nenhum banco disponível, com
`APP_VERSION` definida:

```text
GET /api/version       200  {"version":"a1b2c3d4e5f6...345678"}
GET /api/openapi.json  200
GET /api/docs          200
GET /api/health        503  (esperado: não havia MySQL no ambiente)
pytest                 5 passed
```

Isso confirma a premissa usada pelos scripts de verificação: `/api/version` não
consulta o banco, então a imagem do backend pode ser conferida sozinha, sem
subir MySQL.

## Evidências a anexar após a execução

Preencher depois que o Pull Request rodar e for aprovado:

- [ ] Link do Pull Request:
- [ ] Execução do workflow (Actions) do PR — build sem publicação:
- [ ] Execução do workflow após o merge na `main`:
- [ ] Log do job `backend-smoke`:
- [ ] Log do job `frontend-smoke`:
- [ ] Log do job `verificar-publicacao` (download das imagens):
- [ ] Pacote do backend: <https://github.com/FBurigo/Mensal01/pkgs/container/mensal01-backend>
- [ ] Pacote do frontend: <https://github.com/FBurigo/Mensal01/pkgs/container/mensal01-frontend>
- [ ] Tags publicadas (SHA do commit): `backend:` / `frontend:`
- [ ] Resposta de `/api/version` na aplicação:
- [ ] Print do rodapé mostrando as versões:
- [ ] Saída do `scripts/verificar-imagem-publicada.sh` executado na VM:
- [ ] Revisão do PR por outro integrante:

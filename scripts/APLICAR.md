# Como aplicar estes arquivos

Pacote com o cartão "Build e publicação das imagens Docker" completo — a parte
do Eduardo (frontend, Nginx, download das imagens) e a do Felipe (versão,
backend, associação imagem/commit).

## 1. Copiar por cima do repositório

Copie o conteúdo deste pacote sobre a raiz do repositório `Mensal01`,
mantendo a estrutura de pastas. Não copie este arquivo (`APLICAR.md`).

## 2. Apagar o arquivo substituído

O `frontend/nginx.conf` virou `frontend/nginx.conf.template` e precisa ser
removido, senão fica um arquivo órfão no repositório:

```bash
git rm frontend/nginx.conf
```

## 3. Marcar os scripts como executáveis

```bash
git add scripts/
git update-index --chmod=+x scripts/smoke-backend.sh
git update-index --chmod=+x scripts/smoke-frontend.sh
git update-index --chmod=+x scripts/verificar-imagem-publicada.sh
```

O workflow chama os scripts com `bash ./scripts/...`, então funciona mesmo sem
o bit de execução — isto é só higiene do repositório.

## 4. Branch e Pull Request

```bash
git checkout -b feat/imagens-docker
git add .
git commit -m "feat: build, publicacao e verificacao das imagens no GHCR"
git push -u origin feat/imagens-docker
```

Abra o Pull Request para `main` e peça revisão a outro integrante — a revisão
por outra pessoa é um dos critérios de aceite do cartão.

## 5. Conferir antes do merge

Na execução do Pull Request, verificar em Actions:

- os jobs `Versão e associação com o commit (backend)` e
  `Nginx, proxy /api e segredos (frontend)` passaram;
- o job de build rodou **sem** publicar (nenhuma imagem nova no GHCR).

Depois do merge na `main`:

- as duas imagens aparecem em GHCR com a tag do SHA do commit;
- o job `Download e inicialização das imagens publicadas` passou;
- o resumo da execução traz as tags, os digests e os links dos pacotes.

## 6. Registrar as evidências

Preencher a lista no fim de `docs/EVIDENCIAS-IMAGENS-DOCKER.md` com os links do
PR, das execuções, dos pacotes e a resposta de `/api/version`.

## Antes de publicar, confira

- `IMAGE_OWNER: fburigo` no workflow precisa bater com o dono do pacote no
  GHCR. Se o repositório pertencer a uma organização, o valor muda.
- Em Settings → Actions → General, "Workflow permissions" precisa permitir
  escrita, senão o `GITHUB_TOKEN` não consegue publicar no GHCR.
- Os pacotes nascem privados. Para a VM baixar sem login, torne-os públicos em
  Package settings → Change visibility.

## Arquivos incluídos

| Arquivo | Situação |
|---|---|
| `.gitattributes` | novo |
| `.github/workflows/ci-cd.yml` | alterado |
| `compose.yaml` | alterado |
| `README.md` | alterado |
| `docs/EVIDENCIAS-IMAGENS-DOCKER.md` | novo |
| `backend/Dockerfile` | alterado (rótulos OCI) |
| `backend/.dockerignore` | alterado (lista de permissão) |
| `frontend/Dockerfile` | alterado |
| `frontend/.dockerignore` | alterado |
| `frontend/nginx.conf.template` | novo (substitui `frontend/nginx.conf`) |
| `frontend/security-headers.conf` | novo |
| `frontend/src/index.html` | alterado |
| `frontend/src/app.js` | alterado |
| `frontend/src/styles.css` | alterado |
| `readms/nginx-conf.md` | alterado |
| `readms/frontend-Dockerfile.md` | alterado |
| `readms/backend-Dockerfile.md` | alterado |
| `readms/app-main.md` | alterado |
| `readms/WORKFLOW.md` | alterado |
| `readms/frontend-index-html.md` | alterado |
| `scripts/smoke-backend.sh` | novo |
| `scripts/smoke-frontend.sh` | novo |
| `scripts/verificar-imagem-publicada.sh` | novo |

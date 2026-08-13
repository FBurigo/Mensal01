#!/usr/bin/env bash
#
# Verificação da imagem do backend (cartão "Build e publicação das imagens
# Docker" — responsabilidade do Felipe).
#
# Confere, em cima da imagem já construída:
#   1. que a API sobe e responde;
#   2. que /api/version devolve exatamente o SHA usado no build;
#   3. que a imagem está associada ao commit (tag, rótulo OCI e endpoint);
#   4. que o container não roda como root;
#   5. que nenhum arquivo de segredo ou banco local entrou na imagem.
#
# O comando padrão da imagem roda `alembic upgrade head` antes do Uvicorn e
# precisaria de um MySQL. Como /api/version não toca o banco, aqui o comando é
# substituído por apenas o Uvicorn: a verificação é da identificação da imagem,
# não da integração com o banco (essa está em test_integracao.py).
#
# Uso:
#   ./scripts/smoke-backend.sh <imagem> <versao-esperada>
#   ./scripts/smoke-backend.sh mensal01-backend:ci "$(git rev-parse HEAD)"
set -euo pipefail

IMAGEM="${1:-mensal01-backend:ci}"
VERSAO_ESPERADA="${2:-dev}"
PORTA="${SMOKE_BACKEND_PORT:-8001}"

CONTAINER="smoke-backend-$$"
BASE="http://127.0.0.1:${PORTA}"

falhas=0
ok() { printf '  [ok]    %s\n' "$1"; }
falha() {
  printf '  [FALHA] %s\n' "$1"
  falhas=$((falhas + 1))
}

limpar() { docker rm -f "$CONTAINER" >/dev/null 2>&1 || true; }
trap limpar EXIT

echo "Imagem verificada: ${IMAGEM}"
echo "Versão esperada:   ${VERSAO_ESPERADA}"
echo

# ---------------------------------------------------------------------------
echo "1) A API sobe e informa a versão implantada"
# ---------------------------------------------------------------------------
docker run -d --name "$CONTAINER" -p "127.0.0.1:${PORTA}:8000" "$IMAGEM" \
  uvicorn app.main:app --host 0.0.0.0 --port 8000 >/dev/null

subiu=false
for _ in $(seq 1 30); do
  if curl -fs -m 3 -o /dev/null "${BASE}/api/version"; then
    subiu=true
    break
  fi
  sleep 1
done

if [ "$subiu" = true ]; then
  ok "container no ar e respondendo em /api/version"
else
  falha "a API não respondeu em /api/version"
  docker logs "$CONTAINER" || true
  exit 1
fi

resposta="$(curl -fsS "${BASE}/api/version")"
if [ "$resposta" = "{\"version\":\"${VERSAO_ESPERADA}\"}" ]; then
  ok "/api/version devolve o SHA do commit: ${resposta}"
else
  falha "/api/version devolveu ${resposta}, esperado {\"version\":\"${VERSAO_ESPERADA}\"}"
fi

if curl -fsS -o /dev/null "${BASE}/api/openapi.json"; then
  ok "documentação OpenAPI disponível"
else
  falha "a documentação OpenAPI não respondeu"
fi

# ---------------------------------------------------------------------------
echo
echo "2) Associação entre imagem e commit"
# ---------------------------------------------------------------------------
revisao="$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$IMAGEM")"
if [ "$revisao" = "$VERSAO_ESPERADA" ]; then
  ok "rótulo org.opencontainers.image.revision aponta para o commit"
else
  falha "rótulo de revisão é '${revisao}', esperado '${VERSAO_ESPERADA}'"
fi

variavel="$(docker image inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$IMAGEM" | grep '^APP_VERSION=' | cut -d= -f2-)"
if [ "$variavel" = "$VERSAO_ESPERADA" ]; then
  ok "variável APP_VERSION gravada na imagem"
else
  falha "APP_VERSION na imagem é '${variavel}', esperado '${VERSAO_ESPERADA}'"
fi

# Os três caminhos precisam concordar: só assim a resposta da aplicação em
# produção identifica com segurança o commit que gerou a imagem.
versao_servida="$(printf '%s' "$resposta" | sed 's/.*"version":"\([^"]*\)".*/\1/')"
if [ "$versao_servida" = "$revisao" ] && [ "$versao_servida" = "$variavel" ]; then
  ok "endpoint, rótulo e variável de ambiente concordam"
else
  falha "divergência: endpoint='${versao_servida}' rótulo='${revisao}' env='${variavel}'"
fi

# ---------------------------------------------------------------------------
echo
echo "3) Usuário do container"
# ---------------------------------------------------------------------------
usuario="$(docker run --rm --entrypoint sh "$IMAGEM" -c 'id -un')"
if [ "$usuario" != "root" ]; then
  ok "a aplicação roda como '${usuario}', não como root"
else
  falha "o container está rodando como root"
fi

# ---------------------------------------------------------------------------
echo
echo "4) Nenhum segredo dentro da imagem"
# ---------------------------------------------------------------------------
# A varredura cobre apenas o que a nossa build copiou (/app).
# Procurar na imagem inteira acusaria os certificados raiz publicos de
# /etc/ssl, que sao parte da imagem base e nao segredos do projeto.
arquivos_sensiveis="$(docker run --rm --entrypoint sh "$IMAGEM" -c \
  'find /app -xdev \( -name ".env" -o -name ".env.*" -o -name "*.db" -o -name "*.pem" -o -name "*.key" -o -name "id_rsa" \) -print 2>/dev/null' || true)"
if [ -z "$arquivos_sensiveis" ]; then
  ok "nenhum .env, banco local, chave ou certificado na imagem"
else
  falha "arquivos sensíveis encontrados: ${arquivos_sensiveis}"
fi

conteudo_suspeito="$(docker run --rm --entrypoint sh "$IMAGEM" -c \
  'grep -rilE "MYSQL_ROOT_PASSWORD|GITHUB_TOKEN|BEGIN [A-Z ]*PRIVATE KEY" /app 2>/dev/null' || true)"
if [ -z "$conteudo_suspeito" ]; then
  ok "nenhuma credencial no código copiado para a imagem"
else
  falha "possível credencial em: ${conteudo_suspeito}"
fi

ambiente="$(docker image inspect -f '{{json .Config.Env}}' "$IMAGEM")"
if printf '%s' "$ambiente" | grep -qiE '"[^"]*(PASSWORD|SECRET|TOKEN)[^"]*=[^"]+"'; then
  falha "variáveis de ambiente suspeitas na imagem: ${ambiente}"
else
  ok "nenhuma senha ou token nas variáveis de ambiente da imagem"
fi

# ---------------------------------------------------------------------------
echo
if [ "$falhas" -eq 0 ]; then
  echo "Resultado: todas as verificações passaram."
else
  echo "Resultado: ${falhas} verificação(ões) falharam."
fi
exit "$falhas"

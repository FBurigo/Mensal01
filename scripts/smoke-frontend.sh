#!/usr/bin/env bash
#
# Verificação da imagem do frontend (cartão "Build e publicação das imagens
# Docker" — responsabilidade do Eduardo).
#
# Confere, em cima da imagem já construída:
#   1. que o container inicia sozinho, sem o backend no ar;
#   2. que os arquivos estáticos e a versão da build são servidos;
#   3. que os cabeçalhos de segurança estão presentes, inclusive em CSS/JS;
#   4. que o proxy /api encaminha caminho e query string para o backend;
#   5. que nenhum arquivo de segredo entrou na imagem.
#
# Uso:
#   ./scripts/smoke-frontend.sh <imagem> <versao-esperada>
#   ./scripts/smoke-frontend.sh mensal01-frontend:ci "$(git rev-parse HEAD)"
set -euo pipefail

IMAGEM="${1:-mensal01-frontend:ci}"
VERSAO_ESPERADA="${2:-dev}"
PORTA="${SMOKE_PORT:-8081}"
IMAGEM_STUB="${SMOKE_STUB_IMAGE:-python:3.13-slim}"

SUFIXO="$$"
REDE="smoke-rede-${SUFIXO}"
FRONT="smoke-frontend-${SUFIXO}"
STUB="smoke-backend-${SUFIXO}"
BASE="http://127.0.0.1:${PORTA}"

falhas=0
ok() { printf '  [ok]    %s\n' "$1"; }
falha() {
  printf '  [FALHA] %s\n' "$1"
  falhas=$((falhas + 1))
}

limpar() {
  docker rm -f "$FRONT" "$STUB" >/dev/null 2>&1 || true
  docker network rm "$REDE" >/dev/null 2>&1 || true
}
trap limpar EXIT

esperar_http() {
  local url="$1" tentativas="${2:-30}"
  for _ in $(seq 1 "$tentativas"); do
    if curl -fsS -m 3 -o /dev/null "$url"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

echo "Imagem verificada: ${IMAGEM}"
echo "Versão esperada:   ${VERSAO_ESPERADA}"
echo

# ---------------------------------------------------------------------------
echo "1) A imagem inicia isolada, sem o backend existir"
# ---------------------------------------------------------------------------
docker run -d --name "$FRONT" -p "127.0.0.1:${PORTA}:80" "$IMAGEM" >/dev/null

if esperar_http "${BASE}/healthz"; then
  ok "container no ar e respondendo em /healthz"
else
  falha "o container não respondeu em /healthz"
  docker logs "$FRONT" || true
  exit 1
fi

if curl -fsS "${BASE}/" | grep -q "Estante"; then
  ok "página inicial servida pelo Nginx"
else
  falha "a página inicial não foi servida"
fi

if curl -fsS "${BASE}/version.json" | grep -qF "\"${VERSAO_ESPERADA}\""; then
  ok "/version.json informa a versão da build"
else
  falha "/version.json não trouxe a versão esperada: $(curl -fsS "${BASE}/version.json" || true)"
fi

if [ "$(curl -sS -o /dev/null -w '%{http_code}' "${BASE}/rota-inexistente")" = "200" ]; then
  ok "rotas desconhecidas caem no index.html"
else
  falha "o fallback de SPA não funcionou"
fi

# Sem backend, /api deve falhar de forma controlada, sem derrubar o site.
codigo_api="$(curl -sS -o /dev/null -m 15 -w '%{http_code}' "${BASE}/api/version" || echo 000)"
if [ "$codigo_api" = "502" ] || [ "$codigo_api" = "504" ]; then
  ok "/api responde ${codigo_api} sem backend, como esperado"
else
  falha "/api devolveu ${codigo_api} (esperado 502 ou 504)"
fi

if [ "$(docker inspect -f '{{.State.Running}}' "$FRONT")" = "true" ] &&
  curl -fsS -o /dev/null "${BASE}/"; then
  ok "o site continua no ar mesmo com o backend indisponível"
else
  falha "o container caiu após uma falha do backend"
fi

# ---------------------------------------------------------------------------
echo
echo "2) Cabeçalhos de segurança"
# ---------------------------------------------------------------------------
verificar_cabecalhos() {
  local caminho="$1" rotulo="$2" cabecalhos
  cabecalhos="$(curl -sS -D- -o /dev/null "${BASE}${caminho}")"
  for esperado in "X-Content-Type-Options" "X-Frame-Options" "Referrer-Policy" "Content-Security-Policy"; do
    if printf '%s' "$cabecalhos" | grep -qi "^${esperado}:"; then
      ok "${rotulo}: ${esperado}"
    else
      falha "${rotulo}: ${esperado} ausente"
    fi
  done
}
verificar_cabecalhos "/" "html"
verificar_cabecalhos "/styles.css" "css "

# ---------------------------------------------------------------------------
echo
echo "3) Nenhum segredo dentro da imagem"
# ---------------------------------------------------------------------------
arquivos_sensiveis="$(docker run --rm --entrypoint sh "$IMAGEM" -c \
  'find / -xdev \( -name ".env" -o -name ".env.*" -o -name "*.pem" -o -name "*.key" -o -name "id_rsa" \) -print 2>/dev/null' || true)"
if [ -z "$arquivos_sensiveis" ]; then
  ok "nenhum .env, chave ou certificado na imagem"
else
  falha "arquivos sensíveis encontrados: ${arquivos_sensiveis}"
fi

conteudo_suspeito="$(docker run --rm --entrypoint sh "$IMAGEM" -c \
  'grep -rilE "MYSQL_PASSWORD|MYSQL_ROOT_PASSWORD|DB_PASSWORD|GITHUB_TOKEN|BEGIN [A-Z ]*PRIVATE KEY" /usr/share/nginx/html /etc/nginx 2>/dev/null' || true)"
if [ -z "$conteudo_suspeito" ]; then
  ok "nenhuma credencial nos arquivos servidos ou na configuração"
else
  falha "possível credencial em: ${conteudo_suspeito}"
fi

variaveis="$(docker image inspect -f '{{json .Config.Env}}' "$IMAGEM")"
if printf '%s' "$variaveis" | grep -qiE "PASSWORD|SECRET|TOKEN"; then
  falha "variáveis de ambiente suspeitas na imagem: ${variaveis}"
else
  ok "nenhuma variável de ambiente com senha ou token"
fi

revisao="$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$IMAGEM")"
if [ "$revisao" = "$VERSAO_ESPERADA" ]; then
  ok "rótulo org.opencontainers.image.revision aponta para o commit"
else
  falha "rótulo de revisão é '${revisao}', esperado '${VERSAO_ESPERADA}'"
fi

docker rm -f "$FRONT" >/dev/null

# ---------------------------------------------------------------------------
echo
echo "4) Proxy /api com um backend de teste"
# ---------------------------------------------------------------------------
docker network create "$REDE" >/dev/null

# Backend mínimo, apenas para provar o encaminhamento: responde /api/version e
# /api/books e registra no log o caminho exato que recebeu.
docker run -d --name "$STUB" --network "$REDE" --network-alias backend "$IMAGEM_STUB" \
  sh -c 'mkdir -p /srv/api && printf "{\"version\":\"backend-de-teste\"}\n" > /srv/api/version && printf "[]\n" > /srv/api/books && cd /srv && exec python -m http.server 8000' >/dev/null

docker run -d --name "$FRONT" --network "$REDE" -p "127.0.0.1:${PORTA}:80" "$IMAGEM" >/dev/null

if ! esperar_http "${BASE}/healthz"; then
  falha "o frontend não subiu na rede de teste"
  docker logs "$FRONT" || true
  exit 1
fi

if esperar_http "${BASE}/api/version" 30 &&
  curl -fsS "${BASE}/api/version" | grep -q "backend-de-teste"; then
  ok "/api/version chega ao backend pelo proxy"
else
  falha "o proxy /api não alcançou o backend"
  docker logs "$STUB" || true
fi

if [ "$(curl -sS -o /dev/null -w '%{http_code}' "${BASE}/api/books?q=hobbit&reading_status=LENDO")" = "200" ]; then
  ok "caminho e query string preservados no encaminhamento"
else
  falha "o proxy perdeu o caminho ou a query string"
fi

if docker logs "$STUB" 2>&1 | grep -q "/api/books?q=hobbit&reading_status=LENDO"; then
  ok "o backend recebeu a URL completa (confirmado no log do backend)"
else
  falha "o backend não registrou a URL completa"
  docker logs "$STUB" || true
fi

# ---------------------------------------------------------------------------
echo
if [ "$falhas" -eq 0 ]; then
  echo "Resultado: todas as verificações passaram."
else
  echo "Resultado: ${falhas} verificação(ões) falharam."
fi
exit "$falhas"

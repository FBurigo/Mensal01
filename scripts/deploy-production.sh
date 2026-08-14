#!/usr/bin/env bash

set -Eeuo pipefail

SHA="${1:?Informe o SHA aprovado para implantação.}"
DEPLOY_DIR="${2:-$(pwd)}"
PROJECT_NAME="biblioteca-pessoal"
VOLUME_NAME="mysql_data"

if [[ ! "$SHA" =~ ^[0-9a-f]{40}$ ]]; then
  echo "SHA inválido: use os 40 caracteres hexadecimais do commit aprovado." >&2
  exit 2
fi

cd "$DEPLOY_DIR"

if [[ ! -f .env ]]; then
  echo "Arquivo $DEPLOY_DIR/.env não encontrado; o deploy não alterará credenciais." >&2
  exit 2
fi

export APP_VERSION="$SHA"
COMPOSE=(
  docker compose
  --env-file .env
  -f compose.yaml
  -f compose.production.yaml
)

volume_mysql() {
  docker volume ls --quiet \
    --filter "label=com.docker.compose.project=${PROJECT_NAME}" \
    --filter "label=com.docker.compose.volume=${VOLUME_NAME}" | head -n 1
}

diagnostico() {
  local status="$?"
  trap - EXIT
  if ((status == 0)); then
    return
  fi

  echo "::error::Deploy rejeitado; coletando diagnóstico dos containers." >&2
  "${COMPOSE[@]}" ps --all >&2 || true
  "${COMPOSE[@]}" logs --no-color --tail=200 >&2 || true
  exit "$status"
}
trap diagnostico EXIT

echo "Validando configuração de produção para $SHA"
"${COMPOSE[@]}" config --quiet

volume_antes="$(volume_mysql)"

echo "Baixando imagens imutáveis associadas ao commit"
"${COMPOSE[@]}" pull backend frontend

echo "Atualizando serviços sem reconstruir imagens e sem remover volumes"
"${COMPOSE[@]}" up -d --no-build --wait --wait-timeout 180

if docker port "$("${COMPOSE[@]}" ps -q backend)" 8000/tcp 2>/dev/null |
  grep -q .; then
  echo "A porta 8000 do backend não pode ser publicada." >&2
  exit 1
fi
if docker port "$("${COMPOSE[@]}" ps -q database)" 3306/tcp 2>/dev/null |
  grep -q .; then
  echo "A porta 3306 do MySQL não pode ser publicada." >&2
  exit 1
fi

volume_depois="$(volume_mysql)"
if [[ -z "$volume_depois" ]]; then
  echo "O volume persistente do MySQL não foi encontrado após o deploy." >&2
  exit 1
fi
if [[ -n "$volume_antes" && "$volume_antes" != "$volume_depois" ]]; then
  echo "O volume MySQL mudou de $volume_antes para $volume_depois." >&2
  exit 1
fi

for tentativa in $(seq 1 30); do
  if curl --fail --silent --show-error http://127.0.0.1/healthz >/dev/null &&
    curl --fail --silent --show-error http://127.0.0.1/api/health |
      grep --quiet '"database":"connected"'; then
    break
  fi

  if ((tentativa == 30)); then
    echo "Frontend ou API não ficou saudável após 60 segundos." >&2
    exit 1
  fi
  echo "Tentativa ${tentativa}/30: aguardando frontend e API"
  sleep 2
done

versao_backend="$(curl --fail --silent --show-error http://127.0.0.1/api/version)"
if [[ "$versao_backend" != *"$SHA"* ]]; then
  echo "Versão implantada não corresponde ao SHA esperado: $versao_backend" >&2
  exit 1
fi

curl --fail --silent --show-error http://127.0.0.1/api/books >/dev/null

echo "Deploy aprovado"
echo "SHA: $SHA"
echo "Volume MySQL: $volume_depois"
echo "Saúde: $(curl --fail --silent --show-error http://127.0.0.1/api/health)"
echo "Versão: $versao_backend"
"${COMPOSE[@]}" ps

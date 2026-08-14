#!/usr/bin/env bash

set -Eeuo pipefail

SHA="${1:?Informe o SHA aprovado para implantação.}"
DEPLOY_DIR="${2:-$(pwd)}"
PROJECT_NAME="biblioteca-pessoal"
VOLUME_NAME="mysql_data"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/mensal01}"
ROLLBACK_TEST_MODE="${DEPLOY_FORCE_FAILURE_AFTER_START:-false}"

if [[ ! "$SHA" =~ ^[0-9a-f]{40}$ ]]; then
  echo "SHA inválido: use os 40 caracteres hexadecimais do commit aprovado." >&2
  exit 2
fi

cd "$DEPLOY_DIR"

if [[ ! -f .env ]]; then
  echo "Arquivo $DEPLOY_DIR/.env não encontrado; o deploy não alterará credenciais." >&2
  exit 2
fi

COMPOSE=(
  docker compose
  --env-file .env
  -f compose.yaml
  -f compose.production.yaml
)

rollback_armado=false
versao_anterior=""
volume_inicial=""
backup_file=""

volume_mysql() {
  docker volume ls --quiet \
    --filter "label=com.docker.compose.project=${PROJECT_NAME}" \
    --filter "label=com.docker.compose.volume=${VOLUME_NAME}" | head -n 1
}

extrair_sha() {
  sed -n 's/.*"version":"\([0-9a-f]\{40\}\)".*/\1/p'
}

diagnostico() {
  local version="${1:-$SHA}"
  echo "Coletando estado e últimos logs dos containers" >&2
  APP_VERSION="$version" "${COMPOSE[@]}" ps --all >&2 || true
  APP_VERSION="$version" "${COMPOSE[@]}" logs --no-color --tail=200 >&2 || true
}

validar_implantacao() {
  local expected_sha="$1"
  local health_response version_response deployed_sha current_volume

  if docker port "$(APP_VERSION="$expected_sha" "${COMPOSE[@]}" ps -q backend)" \
    8000/tcp 2>/dev/null | grep -q .; then
    echo "A porta 8000 do backend não pode ser publicada." >&2
    return 1
  fi
  if docker port "$(APP_VERSION="$expected_sha" "${COMPOSE[@]}" ps -q database)" \
    3306/tcp 2>/dev/null | grep -q .; then
    echo "A porta 3306 do MySQL não pode ser publicada." >&2
    return 1
  fi

  current_volume="$(volume_mysql)"
  if [[ -z "$current_volume" || "$current_volume" != "$volume_inicial" ]]; then
    echo "Volume MySQL inesperado: antes=$volume_inicial agora=$current_volume" >&2
    return 1
  fi

  for tentativa in $(seq 1 30); do
    health_response="$(
      curl --fail --silent --show-error http://127.0.0.1/api/health 2>/dev/null
    )" || health_response=""

    if curl --fail --silent --show-error http://127.0.0.1/healthz >/dev/null &&
      [[ "$health_response" == *'"database":"connected"'* ]]; then
      break
    fi

    if ((tentativa == 30)); then
      echo "Frontend ou API não ficou saudável após 60 segundos." >&2
      return 1
    fi
    echo "Tentativa ${tentativa}/30: aguardando frontend, API e banco"
    sleep 2
  done

  version_response="$(
    curl --fail --silent --show-error http://127.0.0.1/api/version
  )" || return 1
  deployed_sha="$(printf '%s' "$version_response" | extrair_sha)"
  if [[ "$deployed_sha" != "$expected_sha" ]]; then
    echo "SHA esperado=$expected_sha implantado=${deployed_sha:-inválido}" >&2
    return 1
  fi

  curl --fail --silent --show-error http://127.0.0.1/api/books >/dev/null || return 1

  echo "Saúde: $health_response"
  echo "Versão: $version_response"
  echo "Volume MySQL: $current_volume"
}

criar_backup_mysql() {
  local timestamp tmp_file checksum_file
  timestamp="$(date -u +'%Y%m%dT%H%M%SZ')"
  backup_file="${BACKUP_DIR}/biblioteca-${timestamp}-${versao_anterior}.sql.gz"
  tmp_file="${backup_file}.tmp"
  checksum_file="${backup_file}.sha256"

  install -d -m 0700 "$BACKUP_DIR"
  echo "Criando backup consistente do MySQL antes da atualização"
  if ! APP_VERSION="$versao_anterior" "${COMPOSE[@]}" exec -T database sh -c \
    'MYSQL_PWD="$MYSQL_PASSWORD" exec mysqldump --single-transaction --quick --skip-lock-tables --no-tablespaces -u"$MYSQL_USER" "$MYSQL_DATABASE"' |
    gzip -9 >"$tmp_file"; then
    rm -f "$tmp_file"
    echo "Backup do MySQL falhou; nenhuma imagem será atualizada." >&2
    return 1
  fi

  if [[ ! -s "$tmp_file" ]]; then
    rm -f "$tmp_file"
    echo "Backup do MySQL ficou vazio; nenhuma imagem será atualizada." >&2
    return 1
  fi

  chmod 0600 "$tmp_file"
  mv "$tmp_file" "$backup_file"
  sha256sum "$backup_file" >"$checksum_file"
  chmod 0600 "$checksum_file"
  echo "Backup: $backup_file ($(du -h "$backup_file" | cut -f1))"
  echo "Checksum: $(cut -d' ' -f1 "$checksum_file")"
}

executar_rollback() {
  echo "::warning::Iniciando rollback para $versao_anterior" >&2

  APP_VERSION="$versao_anterior" "${COMPOSE[@]}" pull backend frontend || return 1
  APP_VERSION="$versao_anterior" "${COMPOSE[@]}" up -d \
    --no-build --wait --wait-timeout 180 || return 1
  validar_implantacao "$versao_anterior" || return 1

  echo "::notice::Rollback concluído e versão anterior restaurada." >&2
  echo "Versão restaurada: $versao_anterior"
  echo "Backup preservado: $backup_file"
}

finalizar() {
  local status="$?" rollback_status
  trap - EXIT
  if ((status == 0)); then
    return
  fi

  echo "::error::Deploy rejeitado; iniciando diagnóstico." >&2
  diagnostico "$SHA"

  if [[ "$rollback_armado" == "true" ]]; then
    set +e
    executar_rollback
    rollback_status="$?"
    set -e
    if ((rollback_status != 0)); then
      echo "::error::Rollback falhou; intervenção manual necessária." >&2
      diagnostico "$versao_anterior"
    fi
  else
    echo "Rollback não foi necessário porque a atualização não começou." >&2
  fi

  # O job permanece falho mesmo quando o rollback restaura a aplicação.
  exit "$status"
}
trap finalizar EXIT

echo "Validando configuração de produção para $SHA"
APP_VERSION="$SHA" "${COMPOSE[@]}" config --quiet

volume_inicial="$(volume_mysql)"
if [[ -z "$volume_inicial" ]]; then
  echo "Volume persistente do MySQL não encontrado antes do deploy." >&2
  exit 1
fi

versao_response="$(curl --fail --silent --show-error http://127.0.0.1/api/version)"
versao_anterior="$(printf '%s' "$versao_response" | extrair_sha)"
if [[ ! "$versao_anterior" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Não foi possível registrar a versão anterior: $versao_response" >&2
  exit 1
fi

echo "Versão anterior: $versao_anterior"
echo "Versão candidata: $SHA"
echo "Volume inicial: $volume_inicial"

criar_backup_mysql

rollback_armado=true
echo "Baixando imagens imutáveis associadas ao commit candidato"
APP_VERSION="$SHA" "${COMPOSE[@]}" pull backend frontend

echo "Atualizando serviços sem reconstruir imagens e sem remover volumes"
APP_VERSION="$SHA" "${COMPOSE[@]}" up -d --no-build --wait --wait-timeout 180
validar_implantacao "$SHA"

if [[ "$ROLLBACK_TEST_MODE" == "true" ]]; then
  echo "::error::Falha controlada do drill de rollback após validação da candidata." >&2
  exit 86
fi

rollback_armado=false
echo "::notice::Deploy aprovado formalmente."
echo "SHA implantado: $SHA"
echo "Backup preservado: $backup_file"
APP_VERSION="$SHA" "${COMPOSE[@]}" ps

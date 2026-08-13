#!/usr/bin/env bash
#
# Baixa as imagens publicadas no GHCR, inicia as duas e confere que cada uma
# corresponde ao commit informado.
#
# Atende aos critérios "as imagens podem ser baixadas pela VM", "a aplicação
# informa a versão implantada" e "cada imagem possui uma tag associada ao SHA".
# Serve tanto no pipeline quanto na máquina virtual do grupo.
#
# Uso na VM:
#   echo "$GHCR_TOKEN" | docker login ghcr.io -u SEU_USUARIO --password-stdin
#   ./scripts/verificar-imagem-publicada.sh <sha-do-commit>
#
# O login só é necessário enquanto os pacotes estiverem privados.
set -euo pipefail

SHA="${1:?Informe o SHA do commit. Ex.: ./scripts/verificar-imagem-publicada.sh 9f2c1ab...}"
REGISTRY="${REGISTRY:-ghcr.io}"
OWNER="${IMAGE_OWNER:-fburigo}"
PORTA_FRONT="${VERIFY_PORT:-8082}"
PORTA_BACK="${VERIFY_BACKEND_PORT:-8083}"

IMAGEM_BACKEND="${REGISTRY}/${OWNER}/mensal01-backend:${SHA}"
IMAGEM_FRONTEND="${REGISTRY}/${OWNER}/mensal01-frontend:${SHA}"
CONT_FRONT="verifica-frontend-$$"
CONT_BACK="verifica-backend-$$"

limpar() { docker rm -f "$CONT_FRONT" "$CONT_BACK" >/dev/null 2>&1 || true; }
trap limpar EXIT

esperar_http() {
  local url="$1"
  for _ in $(seq 1 30); do
    if curl -fsS -m 3 -o /dev/null "$url"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

echo "== Download das imagens publicadas =="
docker pull "$IMAGEM_BACKEND"
docker pull "$IMAGEM_FRONTEND"

digest_backend="$(docker image inspect -f '{{index .RepoDigests 0}}' "$IMAGEM_BACKEND" 2>/dev/null || echo 'não disponível')"
digest_frontend="$(docker image inspect -f '{{index .RepoDigests 0}}' "$IMAGEM_FRONTEND" 2>/dev/null || echo 'não disponível')"
revisao_backend="$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$IMAGEM_BACKEND")"
revisao_frontend="$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$IMAGEM_FRONTEND")"

echo
echo "== Inicialização da imagem do backend =="
# O comando padrão roda as migrations e exigiria um MySQL; aqui interessa
# apenas provar que a imagem baixada inicia e informa a versão implantada.
docker run -d --name "$CONT_BACK" -p "127.0.0.1:${PORTA_BACK}:8000" "$IMAGEM_BACKEND" \
  uvicorn app.main:app --host 0.0.0.0 --port 8000 >/dev/null

if ! esperar_http "http://127.0.0.1:${PORTA_BACK}/api/version"; then
  echo "ERRO: a imagem do backend não respondeu em /api/version."
  docker logs "$CONT_BACK" || true
  exit 1
fi
versao_backend="$(curl -fsS "http://127.0.0.1:${PORTA_BACK}/api/version")"

echo
echo "== Inicialização da imagem do frontend =="
docker run -d --name "$CONT_FRONT" -p "127.0.0.1:${PORTA_FRONT}:80" "$IMAGEM_FRONTEND" >/dev/null

if ! esperar_http "http://127.0.0.1:${PORTA_FRONT}/healthz"; then
  echo "ERRO: a imagem do frontend não respondeu em /healthz."
  docker logs "$CONT_FRONT" || true
  exit 1
fi
versao_frontend="$(curl -fsS "http://127.0.0.1:${PORTA_FRONT}/version.json")"
titulo="$(curl -fsS "http://127.0.0.1:${PORTA_FRONT}/" | grep -o '<title>.*</title>' || true)"

echo
echo "== Resultado =="
echo "  imagem do backend .... ${IMAGEM_BACKEND}"
echo "  digest do backend .... ${digest_backend}"
echo "  rótulo de revisão .... ${revisao_backend}"
echo "  /api/version ......... ${versao_backend}"
echo "  imagem do frontend ... ${IMAGEM_FRONTEND}"
echo "  digest do frontend ... ${digest_frontend}"
echo "  rótulo de revisão .... ${revisao_frontend}"
echo "  /version.json ........ ${versao_frontend}"
echo "  página ............... ${titulo}"

erros=0
conferir() {
  local rotulo="$1" valor="$2"
  if printf '%s' "$valor" | grep -qF "$SHA"; then
    return 0
  fi
  echo "ERRO: ${rotulo} não corresponde ao SHA ${SHA} (valor: ${valor})"
  erros=$((erros + 1))
}
conferir "o rótulo de revisão do backend" "$revisao_backend"
conferir "a resposta de /api/version" "$versao_backend"
conferir "o rótulo de revisão do frontend" "$revisao_frontend"
conferir "a resposta de /version.json" "$versao_frontend"

if [ "$erros" -gt 0 ]; then
  exit 1
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### Download e inicialização das imagens publicadas"
    echo
    echo "| Item | Valor |"
    echo "|---|---|"
    echo "| Backend | \`${IMAGEM_BACKEND}\` |"
    echo "| Digest do backend | \`${digest_backend}\` |"
    echo "| \`/api/version\` da imagem baixada | \`${versao_backend}\` |"
    echo "| Frontend | \`${IMAGEM_FRONTEND}\` |"
    echo "| Digest do frontend | \`${digest_frontend}\` |"
    echo "| \`/version.json\` da imagem baixada | \`${versao_frontend}\` |"
    echo
    echo "Pacotes publicados:"
    echo "- <https://github.com/${OWNER}/Mensal01/pkgs/container/mensal01-backend>"
    echo "- <https://github.com/${OWNER}/Mensal01/pkgs/container/mensal01-frontend>"
  } >>"$GITHUB_STEP_SUMMARY"
fi

echo
echo "As duas imagens foram baixadas, iniciaram e informam o commit ${SHA}."

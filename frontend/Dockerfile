FROM nginx:1.27-alpine

# SHA do commit que originou a imagem. O pipeline envia o valor real;
# em build local sem argumento, a imagem se identifica como "dev".
ARG APP_VERSION=dev

LABEL org.opencontainers.image.title="mensal01-frontend" \
      org.opencontainers.image.description="Frontend Nginx da aplicacao Estante (Biblioteca Pessoal)." \
      org.opencontainers.image.source="https://github.com/FBurigo/Mensal01" \
      org.opencontainers.image.revision="${APP_VERSION}"

# Endereco do backend e DNS usados pelo proxy /api. 127.0.0.11 e o resolvedor
# interno do Docker em redes definidas pelo usuario (Compose). Podem ser
# sobrescritos no `docker run -e` sem reconstruir a imagem.
ENV BACKEND_HOST=backend \
    BACKEND_PORT=8000 \
    NGINX_RESOLVER=127.0.0.11 \
    NGINX_ENVSUBST_FILTER="^(BACKEND_HOST|BACKEND_PORT|NGINX_RESOLVER)$"

COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY security-headers.conf /etc/nginx/snippets/security-headers.conf
COPY src /usr/share/nginx/html

# Versao consultada pela interface em /version.json.
RUN printf '{"version":"%s"}\n' "${APP_VERSION}" > /usr/share/nginx/html/version.json

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://127.0.0.1/healthz || exit 1

EXPOSE 80

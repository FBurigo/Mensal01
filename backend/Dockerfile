FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY alembic.ini .
COPY migrations ./migrations
COPY app ./app

# SHA do commit que originou a imagem. O pipeline envia o valor real;
# em build local sem argumento, a imagem se identifica como "dev".
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

LABEL org.opencontainers.image.title="mensal01-backend" \
      org.opencontainers.image.description="API FastAPI da aplicacao Estante (Biblioteca Pessoal)." \
      org.opencontainers.image.source="https://github.com/FBurigo/Mensal01" \
      org.opencontainers.image.revision="${APP_VERSION}"

USER app
EXPOSE 8000

CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 1"]

# .env.example

**Localização:** `/.env.example`

## O que faz

Template com todas as variáveis de ambiente que o projeto precisa. Deve ser copiado para `.env` e preenchido antes de rodar com Docker Compose.

## Variáveis

| Variável | Padrão no exemplo | Onde é usada |
|---|---|---|
| `MYSQL_DATABASE` | `biblioteca` | Docker Compose → container MySQL + backend |
| `MYSQL_USER` | `biblioteca_app` | Docker Compose → container MySQL + backend |
| `MYSQL_PASSWORD` | *(trocar)* | Docker Compose → MySQL e backend |
| `MYSQL_ROOT_PASSWORD` | *(trocar)* | Docker Compose → MySQL root |
| `APP_PORT` | `80` | Docker Compose → porta pública do frontend |

## Como usar

```bash
cp .env.example .env
# Edite .env e defina senhas reais
```

> **Atenção:** o arquivo `.env` está no `.gitignore` — nunca commite senhas reais.

## Dependências

- Nenhuma — é apenas um arquivo de texto modelo.

# compose.yaml

**Localização:** `/compose.yaml`

## O que faz

Arquivo de orquestração Docker Compose que define e sobe os 3 serviços da aplicação juntos com um único comando.

## Serviços definidos

| Serviço | Imagem/Build | Porta exposta |
|---|---|---|
| `database` | `mysql:8.4` | interna (rede `data`) |
| `backend` | build de `./backend` | `8000` (interna) |
| `frontend` | build de `./frontend` | `80` (host) |

## Ordem de inicialização

```
database (healthcheck) → backend (healthcheck) → frontend
```

O `backend` só sobe depois que o MySQL estiver respondendo. O `frontend` só sobe depois que o backend estiver saudável.

## Redes internas

- **`edge`**: frontend ↔ backend (tráfego HTTP)
- **`data`**: backend ↔ database (tráfego MySQL, isolado do exterior)

## Volume

- `mysql_data`: persiste os dados do MySQL entre reinicializações.

## Variáveis de ambiente usadas

Lidas do arquivo `.env` (ver `.env.example`):

- `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`
- `APP_PORT` (porta do host onde o app ficará disponível, padrão: `80`)

## Como usar

```bash
# Copie o .env.example e preencha as senhas
cp .env.example .env

# Sobe tudo
docker compose up -d

# Para tudo
docker compose down

# Para tudo e apaga o volume do banco
docker compose down -v
```

## Dependências para rodar

- Docker Engine ≥ 24
- Docker Compose plugin (v2)
- Arquivo `.env` com `MYSQL_PASSWORD` e `MYSQL_ROOT_PASSWORD` definidos

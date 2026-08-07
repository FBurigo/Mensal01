# backend/app/main.py

**Localização:** `/backend/app/main.py`

## O que faz

Ponto de entrada da API REST. Define a instância FastAPI e todos os endpoints HTTP do sistema de biblioteca pessoal.

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/api/health` | Verifica saúde da API e do banco |
| `GET` | `/api/books` | Lista livros com busca (`?q=`) e filtro de status (`?reading_status=`) |
| `GET` | `/api/books/{id}` | Retorna um livro pelo ID |
| `POST` | `/api/books` | Cria um novo livro |
| `PUT` | `/api/books/{id}` | Substitui todos os dados de um livro |
| `PATCH` | `/api/books/{id}/status` | Atualiza apenas o status de leitura |
| `DELETE` | `/api/books/{id}` | Remove um livro |

## Comportamentos importantes

- **CORS**: permite requisições de `http://localhost` e `http://localhost:8080`
- **Duplicata de ISBN**: retorna HTTP 409
- **Livro não encontrado**: retorna HTTP 404
- **Banco indisponível no health check**: retorna HTTP 503
- **Docs interativos (Swagger)**: disponíveis em `/api/docs`

## Dependências

- `app/database.py` → `get_db` (sessão do banco)
- `app/models.py` → `Book` (modelo ORM)
- `app/schemas.py` → todos os schemas de entrada/saída
- Libs: `fastapi`, `sqlalchemy`, `uvicorn` (ver `requirements.txt`)

## Como rodar localmente (sem Docker)

```bash
cd backend
pip install -r requirements.txt
# Defina as variáveis de ambiente do banco
uvicorn app.main:app --reload --port 8000
```

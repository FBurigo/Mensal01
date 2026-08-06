# backend/tests/test_books.py

**Localização:** `/backend/tests/test_books.py`

## O que faz

Suite de testes de integração da API usando `pytest` e o `TestClient` do FastAPI. Os testes rodam contra um banco **SQLite em memória** (sem precisar de MySQL nem Docker).

## Como funciona o isolamento

- Sobrescreve a dependência `get_db` do FastAPI com uma sessão SQLite em memória
- Recria toda a estrutura da tabela antes de cada teste via `setup_function()`
- Garante testes independentes e sem estado compartilhado

## Testes implementados

| Teste | O que valida |
|---|---|
| `test_complete_book_lifecycle` | Fluxo completo: criar → buscar → editar → mudar status → deletar |
| `test_rejects_duplicate_isbn` | ISBN duplicado retorna HTTP 409 |
| `test_validates_rating` | Rating inválido (> 5) retorna HTTP 422 |
| `test_health_checks_database` | Endpoint `/api/health` retorna `{"status": "ok", "database": "connected"}` |

## Dependências para rodar

- `app/main.py`, `app/models.py`, `app/database.py` — importados diretamente
- `requirements-dev.txt` instalado (`pytest`, `httpx`)
- **Não precisa** de MySQL nem Docker

## Como executar

```bash
cd backend
pip install -r requirements-dev.txt
pytest tests/
# ou com verbosidade
pytest tests/ -v
```

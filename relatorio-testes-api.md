# Relatório de testes da API - Biblioteca Pessoal

Gerado em: 2026-08-06 21:48:07

**Resultado geral: 14 / 14 testes OK**

## Resumo

| # | Teste | Hora | Esperado | Obtido | Duração | Resultado |
|---|---|---|---|---|---|---|
| 1 | Swagger (/api/docs) | 21:48:07.589 | 200 | 200 | 65ms | OK |
| 2 | Health check (/api/health) | 21:48:07.654 | 200 | 200 | 5ms | OK |
| 3 | Criar livro (POST) | 21:48:07.660 | 201 | 201 | 17ms | OK |
| 4 | Listar livros (GET /api/books) | 21:48:07.677 | 200 | 200 | 8ms | OK |
| 5 | Consultar livro criado (GET /api/books/{id}) | 21:48:07.686 | 200 | 200 | 19ms | OK |
| 6 | Substituir livro (PUT) | 21:48:07.706 | 200 | 200 | 17ms | OK |
| 7 | Alterar status (PATCH /status) | 21:48:07.723 | 200 | 200 | 15ms | OK |
| 8 | Excluir livro (DELETE) | 21:48:07.738 | 204 | 204 | 21ms | OK |
| 9 | Confirmar exclusão (GET id apagado) | 21:48:07.759 | 404 | 404 | 15ms | OK |
| 10 | Rejeitar título vazio (POST) | 21:48:07.776 | 422 | 422 | 8ms | OK |
| 11 | Rejeitar rating fora de 1-5 (POST) | 21:48:07.785 | 422 | 422 | 9ms | OK |
| 12 | Criar livro com ISBN (POST) | 21:48:07.795 | 201 | 201 | 16ms | OK |
| 13 | Rejeitar ISBN duplicado (POST) | 21:48:07.811 | 409 | 409 | 7ms | OK |
| 14 | Limpar livro de teste de ISBN (DELETE) | 21:48:07.819 | 204 | 204 | 27ms | OK |

## Log detalhado por teste

Requisição e resposta reais de cada teste, na ordem em que rodaram.

### 1. Swagger (/api/docs) — OK

- Hora: `21:48:07.589`
- Requisição: `GET http://localhost/api/docs`
- Status esperado: `200` / obtido: `200` (65ms)
- Corpo da resposta:

```json

    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link type="text/css" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
    <link rel="shortcut icon" href="https://fastapi.tiangolo.com/img/favicon.png">
    <title>Biblioteca Pessoal API - Swagger UI</title>
    </head>
    <body>
    <div id="swagger-ui">
    </div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <!-- `SwaggerUIBundle` is now available on the page -->
    <script>
    const ui = SwaggerUIBundle({
        url: '/api/openapi.json',
    "dom_id": "#swagger-ui",
"layout": "BaseLayout",
"deepLinking": true,
"showExtensions": true,
"showCommonExtensions": true,
oauth2RedirectUrl: window.location.origin + '/docs/oauth2-redirect',
    presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIBundle.SwaggerUIStandalonePreset
        ],
    })
    </script>
    </body>
    </html>
    
```

### 2. Health check (/api/health) — OK

- Hora: `21:48:07.654`
- Requisição: `GET http://localhost/api/health`
- Status esperado: `200` / obtido: `200` (5ms)
- Corpo da resposta:

```json
{"status":"ok","database":"connected"}
```

### 3. Criar livro (POST) — OK

- Hora: `21:48:07.660`
- Requisição: `POST http://localhost/api/books`
- Corpo enviado:

```json
{"title": "O Hobbit", "author": "J. R. R. Tolkien", "category": "Fantasia", "reading_status": "LENDO", "isbn": "hob-20260806214807"}
```
- Status esperado: `201` / obtido: `201` (17ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
```

### 4. Listar livros (GET /api/books) — OK

- Hora: `21:48:07.677`
- Requisição: `GET http://localhost/api/books`
- Status esperado: `200` / obtido: `200` (8ms)
- Corpo da resposta:

```json
[{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"},{"title":"bi","author":"h9-","isbn":null,"category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":14,"created_at":"2026-08-07T00:03:07","updated_at":"2026-08-07T00:03:07"},{"title":"A","author":"B","isbn":"111","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":2,"created_at":"2026-08-06T23:21:11","updated_at":"2026-08-06T23:21:11"}]
```

### 5. Consultar livro criado (GET /api/books/{id}) — OK

- Hora: `21:48:07.686`
- Requisição: `GET http://localhost/api/books/20`
- Status esperado: `200` / obtido: `200` (19ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
```

### 6. Substituir livro (PUT) — OK

- Hora: `21:48:07.706`
- Requisição: `PUT http://localhost/api/books/20`
- Corpo enviado:

```json
{"title": "O Hobbit", "author": "J. R. R. Tolkien", "category": "Fantasia", "reading_status": "LIDO", "rating": 5, "isbn": "hob-20260806214807"}
```
- Status esperado: `200` / obtido: `200` (17ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LIDO","rating":5,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
```

### 7. Alterar status (PATCH /status) — OK

- Hora: `21:48:07.723`
- Requisição: `PATCH http://localhost/api/books/20/status`
- Corpo enviado:

```json
{"reading_status": "LENDO"}
```
- Status esperado: `200` / obtido: `200` (15ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":5,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
```

### 8. Excluir livro (DELETE) — OK

- Hora: `21:48:07.738`
- Requisição: `DELETE http://localhost/api/books/20`
- Status esperado: `204` / obtido: `204` (21ms)
- Corpo da resposta:

```json

```

### 9. Confirmar exclusão (GET id apagado) — OK

- Hora: `21:48:07.759`
- Requisição: `GET http://localhost/api/books/20`
- Status esperado: `404` / obtido: `404` (15ms)
- Corpo da resposta:

```json
{"detail":"Livro não encontrado."}
```

### 10. Rejeitar título vazio (POST) — OK

- Hora: `21:48:07.776`
- Requisição: `POST http://localhost/api/books`
- Corpo enviado:

```json
{"title": "", "author": "X"}
```
- Status esperado: `422` / obtido: `422` (8ms)
- Corpo da resposta:

```json
{"detail":[{"type":"string_too_short","loc":["body","title"],"msg":"String should have at least 1 character","input":"","ctx":{"min_length":1}}]}
```

### 11. Rejeitar rating fora de 1-5 (POST) — OK

- Hora: `21:48:07.785`
- Requisição: `POST http://localhost/api/books`
- Corpo enviado:

```json
{"title": "A", "author": "B", "rating": 9}
```
- Status esperado: `422` / obtido: `422` (9ms)
- Corpo da resposta:

```json
{"detail":[{"type":"less_than_equal","loc":["body","rating"],"msg":"Input should be less than or equal to 5","input":9,"ctx":{"le":5}}]}
```

### 12. Criar livro com ISBN (POST) — OK

- Hora: `21:48:07.795`
- Requisição: `POST http://localhost/api/books`
- Corpo enviado:

```json
{"title": "Livro A", "author": "X", "isbn": "dup-20260806214807"}
```
- Status esperado: `201` / obtido: `201` (16ms)
- Corpo da resposta:

```json
{"title":"Livro A","author":"X","isbn":"dup-20260806214807","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":21,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
```

### 13. Rejeitar ISBN duplicado (POST) — OK

- Hora: `21:48:07.811`
- Requisição: `POST http://localhost/api/books`
- Corpo enviado:

```json
{"title": "Livro B", "author": "Y", "isbn": "dup-20260806214807"}
```
- Status esperado: `409` / obtido: `409` (7ms)
- Corpo da resposta:

```json
{"detail":"Já existe um livro com este ISBN."}
```

### 14. Limpar livro de teste de ISBN (DELETE) — OK

- Hora: `21:48:07.819`
- Requisição: `DELETE http://localhost/api/books/21`
- Status esperado: `204` / obtido: `204` (27ms)
- Corpo da resposta:

```json

```

## Log completo da execução

Saída de console completa e sem edição, na ordem em que os testes rodaram.

```text

======================================================================
TESTE: Swagger (/api/docs)
Hora: 2026-08-06 21:48:07.589
Requisicao: GET http://localhost/api/docs
Status esperado: 200 | Status obtido: 200 | Duracao: 65ms
Corpo da resposta: 
    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link type="text/css" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
    <link rel="shortcut icon" href="https://fastapi.tiangolo.com/img/favicon.png">
    <title>Biblioteca Pessoal API - Swagger UI</title>
    </head>
    <body>
    <div id="swagger-ui">
    </div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <!-- `SwaggerUIBundle` is now available on the page -->
    <script>
    const ui = SwaggerUIBundle({
        url: '/api/openapi.json',
    "dom_id": "#swagger-ui",
"layout": "BaseLayout",
"deepLinking": true,
"showExtensions": true,
"showCommonExtensions": true,
oauth2RedirectUrl: window.location.origin + '/docs/oauth2-redirect',
    presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIBundle.SwaggerUIStandalonePreset
        ],
    })
    </script>
    </body>
    </html>
    
Resultado: OK
======================================================================

======================================================================
TESTE: Health check (/api/health)
Hora: 2026-08-06 21:48:07.654
Requisicao: GET http://localhost/api/health
Status esperado: 200 | Status obtido: 200 | Duracao: 5ms
Corpo da resposta: {"status":"ok","database":"connected"}
Resultado: OK
======================================================================

======================================================================
TESTE: Criar livro (POST)
Hora: 2026-08-06 21:48:07.660
Requisicao: POST http://localhost/api/books
Corpo enviado: {"title": "O Hobbit", "author": "J. R. R. Tolkien", "category": "Fantasia", "reading_status": "LENDO", "isbn": "hob-20260806214807"}
Status esperado: 201 | Status obtido: 201 | Duracao: 17ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
Resultado: OK
======================================================================

======================================================================
TESTE: Listar livros (GET /api/books)
Hora: 2026-08-06 21:48:07.677
Requisicao: GET http://localhost/api/books
Status esperado: 200 | Status obtido: 200 | Duracao: 8ms
Corpo da resposta: [{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"},{"title":"bi","author":"h9-","isbn":null,"category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":14,"created_at":"2026-08-07T00:03:07","updated_at":"2026-08-07T00:03:07"},{"title":"A","author":"B","isbn":"111","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":2,"created_at":"2026-08-06T23:21:11","updated_at":"2026-08-06T23:21:11"}]
Resultado: OK
======================================================================

======================================================================
TESTE: Consultar livro criado (GET /api/books/{id})
Hora: 2026-08-06 21:48:07.686
Requisicao: GET http://localhost/api/books/20
Status esperado: 200 | Status obtido: 200 | Duracao: 19ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
Resultado: OK
======================================================================

======================================================================
TESTE: Substituir livro (PUT)
Hora: 2026-08-06 21:48:07.706
Requisicao: PUT http://localhost/api/books/20
Corpo enviado: {"title": "O Hobbit", "author": "J. R. R. Tolkien", "category": "Fantasia", "reading_status": "LIDO", "rating": 5, "isbn": "hob-20260806214807"}
Status esperado: 200 | Status obtido: 200 | Duracao: 17ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LIDO","rating":5,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
Resultado: OK
======================================================================

======================================================================
TESTE: Alterar status (PATCH /status)
Hora: 2026-08-06 21:48:07.723
Requisicao: PATCH http://localhost/api/books/20/status
Corpo enviado: {"reading_status": "LENDO"}
Status esperado: 200 | Status obtido: 200 | Duracao: 15ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806214807","category":"Fantasia","reading_status":"LENDO","rating":5,"notes":null,"id":20,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
Resultado: OK
======================================================================

======================================================================
TESTE: Excluir livro (DELETE)
Hora: 2026-08-06 21:48:07.738
Requisicao: DELETE http://localhost/api/books/20
Status esperado: 204 | Status obtido: 204 | Duracao: 21ms
Corpo da resposta: 
Resultado: OK
======================================================================

======================================================================
TESTE: Confirmar exclusão (GET id apagado)
Hora: 2026-08-06 21:48:07.759
Requisicao: GET http://localhost/api/books/20
Status esperado: 404 | Status obtido: 404 | Duracao: 15ms
Corpo da resposta: {"detail":"Livro não encontrado."}
Resultado: OK
======================================================================

======================================================================
TESTE: Rejeitar título vazio (POST)
Hora: 2026-08-06 21:48:07.776
Requisicao: POST http://localhost/api/books
Corpo enviado: {"title": "", "author": "X"}
Status esperado: 422 | Status obtido: 422 | Duracao: 8ms
Corpo da resposta: {"detail":[{"type":"string_too_short","loc":["body","title"],"msg":"String should have at least 1 character","input":"","ctx":{"min_length":1}}]}
Resultado: OK
======================================================================

======================================================================
TESTE: Rejeitar rating fora de 1-5 (POST)
Hora: 2026-08-06 21:48:07.785
Requisicao: POST http://localhost/api/books
Corpo enviado: {"title": "A", "author": "B", "rating": 9}
Status esperado: 422 | Status obtido: 422 | Duracao: 9ms
Corpo da resposta: {"detail":[{"type":"less_than_equal","loc":["body","rating"],"msg":"Input should be less than or equal to 5","input":9,"ctx":{"le":5}}]}
Resultado: OK
======================================================================

======================================================================
TESTE: Criar livro com ISBN (POST)
Hora: 2026-08-06 21:48:07.795
Requisicao: POST http://localhost/api/books
Corpo enviado: {"title": "Livro A", "author": "X", "isbn": "dup-20260806214807"}
Status esperado: 201 | Status obtido: 201 | Duracao: 16ms
Corpo da resposta: {"title":"Livro A","author":"X","isbn":"dup-20260806214807","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":21,"created_at":"2026-08-07T00:48:07","updated_at":"2026-08-07T00:48:07"}
Resultado: OK
======================================================================

======================================================================
TESTE: Rejeitar ISBN duplicado (POST)
Hora: 2026-08-06 21:48:07.811
Requisicao: POST http://localhost/api/books
Corpo enviado: {"title": "Livro B", "author": "Y", "isbn": "dup-20260806214807"}
Status esperado: 409 | Status obtido: 409 | Duracao: 7ms
Corpo da resposta: {"detail":"Já existe um livro com este ISBN."}
Resultado: OK
======================================================================

======================================================================
TESTE: Limpar livro de teste de ISBN (DELETE)
Hora: 2026-08-06 21:48:07.819
Requisicao: DELETE http://localhost/api/books/21
Status esperado: 204 | Status obtido: 204 | Duracao: 27ms
Corpo da resposta: 
Resultado: OK
======================================================================
```
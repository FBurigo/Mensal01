# Relatﾃｳrio de testes da API - Biblioteca Pessoal

Gerado em: 2026-08-06 20:42:36

**Resultado geral: 14 / 14 testes OK**

## Resumo

| # | Teste | Hora | Esperado | Obtido | Duraﾃｧﾃ｣o | Resultado |
|---|---|---|---|---|---|---|
| 1 | Swagger (/api/docs) | 20:42:35.132 | 200 | 200 | 59ms | OK |
| 2 | Health check (/api/health) | 20:42:35.222 | 200 | 200 | 17ms | OK |
| 3 | Criar livro (POST) | 20:42:35.265 | 201 | 201 | 66ms | OK |
| 4 | Listar livros (GET /api/books) | 20:42:35.353 | 200 | 200 | 18ms | OK |
| 5 | Consultar livro criado (GET /api/books/{id}) | 20:42:35.379 | 200 | 200 | 17ms | OK |
| 6 | Substituir livro (PUT) | 20:42:35.403 | 200 | 200 | 65ms | OK |
| 7 | Alterar status (PATCH /status) | 20:42:35.476 | 200 | 200 | 61ms | OK |
| 8 | Excluir livro (DELETE) | 20:42:35.544 | 204 | 204 | 16ms | OK |
| 9 | Confirmar exclusﾃ｣o (GET id apagado) | 20:42:35.569 | 404 | 404 | 16ms | OK |
| 10 | Rejeitar tﾃｭtulo vazio (POST) | 20:42:35.596 | 422 | 422 | 49ms | OK |
| 11 | Rejeitar rating fora de 1-5 (POST) | 20:42:35.652 | 422 | 422 | 47ms | OK |
| 12 | Criar livro com ISBN (POST) | 20:42:35.708 | 201 | 201 | 64ms | OK |
| 13 | Rejeitar ISBN duplicado (POST) | 20:42:35.781 | 409 | 409 | 51ms | OK |
| 14 | Limpar livro de teste de ISBN (DELETE) | 20:42:35.839 | 204 | 204 | 12ms | OK |

## Log detalhado por teste

Requisiﾃｧﾃ｣o e resposta reais de cada teste, na ordem em que rodaram.

### 1. Swagger (/api/docs) 窶・OK

- Hora: `20:42:35.132`
- Requisiﾃｧﾃ｣o: `GET http://localhost/api/docs`
- Status esperado: `200` / obtido: `200` (59ms)
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

### 2. Health check (/api/health) 窶・OK

- Hora: `20:42:35.222`
- Requisiﾃｧﾃ｣o: `GET http://localhost/api/health`
- Status esperado: `200` / obtido: `200` (17ms)
- Corpo da resposta:

```json
{"status":"ok","database":"connected"}
```

### 3. Criar livro (POST) 窶・OK

- Hora: `20:42:35.265`
- Requisiﾃｧﾃ｣o: `POST http://localhost/api/books`
- Corpo enviado:

```json
{
    "title":  "O Hobbit",
    "category":  "Fantasia",
    "author":  "J. R. R. Tolkien",
    "reading_status":  "LENDO",
    "isbn":  "hob-20260806204235"
}
```
- Status esperado: `201` / obtido: `201` (66ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
```

### 4. Listar livros (GET /api/books) 窶・OK

- Hora: `20:42:35.353`
- Requisiﾃｧﾃ｣o: `GET http://localhost/api/books`
- Status esperado: `200` / obtido: `200` (18ms)
- Corpo da resposta:

```json
[{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"},{"title":"A","author":"B","isbn":"111","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":2,"created_at":"2026-08-06T23:21:11","updated_at":"2026-08-06T23:21:11"}]
```

### 5. Consultar livro criado (GET /api/books/{id}) 窶・OK

- Hora: `20:42:35.379`
- Requisiﾃｧﾃ｣o: `GET http://localhost/api/books/7`
- Status esperado: `200` / obtido: `200` (17ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
```

### 6. Substituir livro (PUT) 窶・OK

- Hora: `20:42:35.403`
- Requisiﾃｧﾃ｣o: `PUT http://localhost/api/books/7`
- Corpo enviado:

```json
{
    "author":  "J. R. R. Tolkien",
    "reading_status":  "LIDO",
    "rating":  5,
    "isbn":  "hob-20260806204235",
    "category":  "Fantasia",
    "title":  "O Hobbit"
}
```
- Status esperado: `200` / obtido: `200` (65ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LIDO","rating":5,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
```

### 7. Alterar status (PATCH /status) 窶・OK

- Hora: `20:42:35.476`
- Requisiﾃｧﾃ｣o: `PATCH http://localhost/api/books/7/status`
- Corpo enviado:

```json
{
    "reading_status":  "LENDO"
}
```
- Status esperado: `200` / obtido: `200` (61ms)
- Corpo da resposta:

```json
{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":5,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
```

### 8. Excluir livro (DELETE) 窶・OK

- Hora: `20:42:35.544`
- Requisiﾃｧﾃ｣o: `DELETE http://localhost/api/books/7`
- Status esperado: `204` / obtido: `204` (16ms)
- Corpo da resposta:

```json
```

### 9. Confirmar exclusﾃ｣o (GET id apagado) 窶・OK

- Hora: `20:42:35.569`
- Requisiﾃｧﾃ｣o: `GET http://localhost/api/books/7`
- Status esperado: `404` / obtido: `404` (16ms)
- Corpo da resposta:

```json
{"detail":"Livro não encontrado."}
```

### 10. Rejeitar tﾃｭtulo vazio (POST) 窶・OK

- Hora: `20:42:35.596`
- Requisiﾃｧﾃ｣o: `POST http://localhost/api/books`
- Corpo enviado:

```json
{
    "author":  "X",
    "title":  ""
}
```
- Status esperado: `422` / obtido: `422` (49ms)
- Corpo da resposta:

```json
{"detail":[{"type":"string_too_short","loc":["body","title"],"msg":"String should have at least 1 character","input":"","ctx":{"min_length":1}}]}
```

### 11. Rejeitar rating fora de 1-5 (POST) 窶・OK

- Hora: `20:42:35.652`
- Requisiﾃｧﾃ｣o: `POST http://localhost/api/books`
- Corpo enviado:

```json
{
    "title":  "A",
    "rating":  9,
    "author":  "B"
}
```
- Status esperado: `422` / obtido: `422` (47ms)
- Corpo da resposta:

```json
{"detail":[{"type":"less_than_equal","loc":["body","rating"],"msg":"Input should be less than or equal to 5","input":9,"ctx":{"le":5}}]}
```

### 12. Criar livro com ISBN (POST) 窶・OK

- Hora: `20:42:35.708`
- Requisiﾃｧﾃ｣o: `POST http://localhost/api/books`
- Corpo enviado:

```json
{
    "title":  "Livro A",
    "author":  "X",
    "isbn":  "dup-20260806204235"
}
```
- Status esperado: `201` / obtido: `201` (64ms)
- Corpo da resposta:

```json
{"title":"Livro A","author":"X","isbn":"dup-20260806204235","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":8,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
```

### 13. Rejeitar ISBN duplicado (POST) 窶・OK

- Hora: `20:42:35.781`
- Requisiﾃｧﾃ｣o: `POST http://localhost/api/books`
- Corpo enviado:

```json
{
    "title":  "Livro B",
    "author":  "Y",
    "isbn":  "dup-20260806204235"
}
```
- Status esperado: `409` / obtido: `409` (51ms)
- Corpo da resposta:

```json
{"detail":"Já existe um livro com este ISBN."}
```

### 14. Limpar livro de teste de ISBN (DELETE) 窶・OK

- Hora: `20:42:35.839`
- Requisiﾃｧﾃ｣o: `DELETE http://localhost/api/books/8`
- Status esperado: `204` / obtido: `204` (12ms)
- Corpo da resposta:

```json
```

## Log completo da execuﾃｧﾃ｣o (transcript bruto)

Saﾃｭda de console completa e sem ediﾃｧﾃ｣o, gerada pelo Start-Transcript do
PowerShell durante a execuﾃｧﾃ｣o deste script 窶・serve como prova de que os
testes acima realmente rodaram, na ordem mostrada.

```text
**********************
Início da transcrição do Windows PowerShell
Hora de início: 20260806204235
Nome de Usuário: NEKO-PC\NEKO
Executar como Usuário: NEKO-PC\NEKO
Nome da Configuração: 
Computador: NEKO-PC (Microsoft Windows NT 10.0.26200.0)
Aplicativo Host: powershell -NoProfile -ExecutionPolicy Bypass -File G:\Outros computadores\Meu laptop (1)\driver facul\semestre 8\Mensal01\test-api.ps1
ID do Processo: 69140
PSVersion: 5.1.26100.8875
PSEdition: Desktop
PSCompatibleVersions: 1.0, 2.0, 3.0, 4.0, 5.0, 5.1.26100.8875
BuildVersion: 10.0.26100.8875
CLRVersion: 4.0.30319.42000
WSManStackVersion: 3.0
PSRemotingProtocolVersion: 2.3
SerializationVersion: 1.1.0.1
**********************

===================================================================
TESTE: Swagger (/api/docs)
Hora: 2026-08-06 20:42:35.132
Requisicao: GET http://localhost/api/docs
Status esperado: 200 | Status obtido: 200 | Duracao: 59ms
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
===================================================================

===================================================================
TESTE: Health check (/api/health)
Hora: 2026-08-06 20:42:35.222
Requisicao: GET http://localhost/api/health
Status esperado: 200 | Status obtido: 200 | Duracao: 17ms
Corpo da resposta: {"status":"ok","database":"connected"}
Resultado: OK
===================================================================

===================================================================
TESTE: Criar livro (POST)
Hora: 2026-08-06 20:42:35.265
Requisicao: POST http://localhost/api/books
Corpo enviado: {
    "title":  "O Hobbit",
    "category":  "Fantasia",
    "author":  "J. R. R. Tolkien",
    "reading_status":  "LENDO",
    "isbn":  "hob-20260806204235"
}
Status esperado: 201 | Status obtido: 201 | Duracao: 66ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
Resultado: OK
===================================================================

===================================================================
TESTE: Listar livros (GET /api/books)
Hora: 2026-08-06 20:42:35.353
Requisicao: GET http://localhost/api/books
Status esperado: 200 | Status obtido: 200 | Duracao: 18ms
Corpo da resposta: [{"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"},{"title":"A","author":"B","isbn":"111","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":2,"created_at":"2026-08-06T23:21:11","updated_at":"2026-08-06T23:21:11"}]
Resultado: OK
===================================================================

===================================================================
TESTE: Consultar livro criado (GET /api/books/{id})
Hora: 2026-08-06 20:42:35.379
Requisicao: GET http://localhost/api/books/7
Status esperado: 200 | Status obtido: 200 | Duracao: 17ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":null,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
Resultado: OK
===================================================================

===================================================================
TESTE: Substituir livro (PUT)
Hora: 2026-08-06 20:42:35.403
Requisicao: PUT http://localhost/api/books/7
Corpo enviado: {
    "author":  "J. R. R. Tolkien",
    "reading_status":  "LIDO",
    "rating":  5,
    "isbn":  "hob-20260806204235",
    "category":  "Fantasia",
    "title":  "O Hobbit"
}
Status esperado: 200 | Status obtido: 200 | Duracao: 65ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LIDO","rating":5,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
Resultado: OK
===================================================================

===================================================================
TESTE: Alterar status (PATCH /status)
Hora: 2026-08-06 20:42:35.476
Requisicao: PATCH http://localhost/api/books/7/status
Corpo enviado: {
    "reading_status":  "LENDO"
}
Status esperado: 200 | Status obtido: 200 | Duracao: 61ms
Corpo da resposta: {"title":"O Hobbit","author":"J. R. R. Tolkien","isbn":"hob-20260806204235","category":"Fantasia","reading_status":"LENDO","rating":5,"notes":null,"id":7,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
Resultado: OK
===================================================================

===================================================================
TESTE: Excluir livro (DELETE)
Hora: 2026-08-06 20:42:35.544
Requisicao: DELETE http://localhost/api/books/7
Status esperado: 204 | Status obtido: 204 | Duracao: 16ms
Corpo da resposta:
Resultado: OK
===================================================================
PS>TerminatingError(Invoke-WebRequest): "{"detail":"Livro não encontrado."}"

===================================================================
TESTE: Confirmar exclusﾃ｣o (GET id apagado)
Hora: 2026-08-06 20:42:35.569
Requisicao: GET http://localhost/api/books/7
Status esperado: 404 | Status obtido: 404 | Duracao: 16ms
Corpo da resposta: {"detail":"Livro não encontrado."}
Resultado: OK
===================================================================
PS>TerminatingError(Invoke-WebRequest): "{"detail":[{"type":"string_too_short","loc":["body","title"],"msg":"String should have at least 1 character","input":"","ctx":{"min_length":1}}]}"

===================================================================
TESTE: Rejeitar tﾃｭtulo vazio (POST)
Hora: 2026-08-06 20:42:35.596
Requisicao: POST http://localhost/api/books
Corpo enviado: {
    "author":  "X",
    "title":  ""
}
Status esperado: 422 | Status obtido: 422 | Duracao: 49ms
Corpo da resposta: {"detail":[{"type":"string_too_short","loc":["body","title"],"msg":"String should have at least 1 character","input":"","ctx":{"min_length":1}}]}
Resultado: OK
===================================================================
PS>TerminatingError(Invoke-WebRequest): "{"detail":[{"type":"less_than_equal","loc":["body","rating"],"msg":"Input should be less than or equal to 5","input":9,"ctx":{"le":5}}]}"

===================================================================
TESTE: Rejeitar rating fora de 1-5 (POST)
Hora: 2026-08-06 20:42:35.652
Requisicao: POST http://localhost/api/books
Corpo enviado: {
    "title":  "A",
    "rating":  9,
    "author":  "B"
}
Status esperado: 422 | Status obtido: 422 | Duracao: 47ms
Corpo da resposta: {"detail":[{"type":"less_than_equal","loc":["body","rating"],"msg":"Input should be less than or equal to 5","input":9,"ctx":{"le":5}}]}
Resultado: OK
===================================================================

===================================================================
TESTE: Criar livro com ISBN (POST)
Hora: 2026-08-06 20:42:35.708
Requisicao: POST http://localhost/api/books
Corpo enviado: {
    "title":  "Livro A",
    "author":  "X",
    "isbn":  "dup-20260806204235"
}
Status esperado: 201 | Status obtido: 201 | Duracao: 64ms
Corpo da resposta: {"title":"Livro A","author":"X","isbn":"dup-20260806204235","category":"Geral","reading_status":"QUERO_LER","rating":null,"notes":null,"id":8,"created_at":"2026-08-06T23:42:35","updated_at":"2026-08-06T23:42:35"}
Resultado: OK
===================================================================
PS>TerminatingError(Invoke-WebRequest): "{"detail":"Já existe um livro com este ISBN."}"

===================================================================
TESTE: Rejeitar ISBN duplicado (POST)
Hora: 2026-08-06 20:42:35.781
Requisicao: POST http://localhost/api/books
Corpo enviado: {
    "title":  "Livro B",
    "author":  "Y",
    "isbn":  "dup-20260806204235"
}
Status esperado: 409 | Status obtido: 409 | Duracao: 51ms
Corpo da resposta: {"detail":"Já existe um livro com este ISBN."}
Resultado: OK
===================================================================

===================================================================
TESTE: Limpar livro de teste de ISBN (DELETE)
Hora: 2026-08-06 20:42:35.839
Requisicao: DELETE http://localhost/api/books/8
Status esperado: 204 | Status obtido: 204 | Duracao: 12ms
Corpo da resposta:
Resultado: OK
===================================================================
**********************
Fim da transcrição do Windows PowerShell
Hora de término: 20260806204235
**********************

```
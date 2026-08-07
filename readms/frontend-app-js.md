# frontend/src/app.js

**Localização:** `/frontend/src/app.js`

## O que faz

Toda a lógica JavaScript da aplicação "Estante". Gerencia a interface do usuário e a comunicação com a API REST do backend. Não usa nenhum framework — JavaScript puro.

## Responsabilidades

| Função | Descrição |
|---|---|
| `loadBooks()` | Busca a lista de livros da API com filtros ativos |
| `renderBooks()` | Renderiza os cards de livros na grade |
| `bookCard(book)` | Gera o HTML de um card individual de livro |
| `updateStats()` | Atualiza os contadores (total, lendo, lidos) |
| `openCreateDialog()` | Abre o modal em modo "Adicionar" |
| `openEditDialog(id)` | Abre o modal em modo "Editar" com os dados do livro |
| `saveBook(event)` | Submete o formulário: POST (novo) ou PUT (edição) |
| `changeStatus(id, status)` | PATCH no status de leitura via dropdown do card |
| `removeBook(id)` | DELETE após confirmação do usuário |
| `showToast(message, isError)` | Exibe notificação temporária na tela |

## Endpoints consumidos

| Operação | Método | Rota |
|---|---|---|
| Listar/buscar | GET | `/api/books?q=&reading_status=` |
| Criar | POST | `/api/books` |
| Editar completo | PUT | `/api/books/{id}` |
| Mudar status | PATCH | `/api/books/{id}/status` |
| Excluir | DELETE | `/api/books/{id}` |

## Comportamento de busca

Usa debounce de 300ms no campo de busca para não disparar chamadas à API a cada tecla.

## Dependências

- `frontend/src/index.html` — fornece os elementos DOM manipulados
- Backend rodando e acessível em `/api/` (via Nginx proxy)
- Nenhuma biblioteca externa

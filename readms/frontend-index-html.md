# frontend/src/index.html

**Localização:** `/frontend/src/index.html`

## O que faz

Página HTML principal (e única) da aplicação "Estante". É uma SPA (Single Page Application) — toda a interatividade é gerenciada pelo JavaScript sem recarregar a página.

## Estrutura da página

| Seção | Descrição |
|---|---|
| `<header>` topbar | Logo "Estante" + botão "Adicionar livro" |
| `<section>` hero | Título e decoração visual |
| `<section>` stats | Contadores: total, lendo, lidos |
| `<section>` library | Grade de livros com busca e filtro por status |
| `<dialog>` book-dialog | Modal com formulário para criar/editar livro |
| `<div>` toast | Notificações temporárias de sucesso/erro |
| `<footer>` | Rodapé com identificação do projeto |

## Recursos carregados

- `styles.css` — estilos da página
- `app.js` — lógica JavaScript (carregado com `defer`)

## Dependências

- `frontend/src/styles.css` — visual
- `frontend/src/app.js` — comportamento
- `frontend/nginx.conf.template` — serve este arquivo como raiz do site

# frontend/src/styles.css

**Localização:** `/frontend/src/styles.css`

## O que faz

Folha de estilos completa da aplicação "Estante". Define o visual de todos os componentes sem uso de framework CSS.

## Variáveis CSS (design tokens)

Definidas em `:root`:

| Variável | Valor | Uso |
|---|---|---|
| `--ink` | `#202722` | Texto principal |
| `--muted` | `#667068` | Texto secundário |
| `--cream` | `#f7f4ed` | Fundo da página |
| `--paper` | `#fffdf8` | Fundo de cards/modais |
| `--green` | `#215c4a` | Cor primária (botões, marca) |
| `--terracotta` | `#bd694e` | Status "Quero ler" / destaques |
| `--gold` | `#dcae55` | Status "Lido" / estrelas |
| `--mint` | `#dce9df` | Status "Lendo" / badges |

## Principais componentes estilizados

- `.topbar` — barra de navegação fixa com blur
- `.hero` — seção de apresentação com decoração de livros animados
- `.stats` — grade de 3 cards de métricas
- `.book-grid` — grade responsiva de cards de livros
- `.book-card` — card individual com borda colorida por status
- `dialog` — modal de criação/edição de livros
- `.toast` — notificação flutuante animada
- `.button-primary` / `.button-secondary` — botões da interface

## Responsividade

- `≤ 960px`: hero em coluna única, grid de 2 colunas
- `≤ 680px`: layout mobile completo, grid de 1 coluna, formulário em coluna única

## Dependências

- `frontend/src/index.html` — referencia este arquivo via `<link rel="stylesheet">`
- Nenhuma biblioteca externa — CSS puro

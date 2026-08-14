# Estante — Gerenciador de Biblioteca Pessoal

Aplicação Web acadêmica para cadastrar e acompanhar livros de uma biblioteca
pessoal. O projeto foi pensado para a primeira entrega de Cloud: simples de
demonstrar, com frontend, backend e banco de dados executados em serviços
separados e com persistência.

## Aplicação publicada

- aplicação: <http://35.238.205.240/>
- saúde da API e do banco: <http://35.238.205.240/api/health>
- documentação REST: <http://35.238.205.240/api/docs>
- Kanban: <https://github.com/users/FBurigo/projects/2>

O ambiente utiliza somente dados acadêmicos de demonstração. Nesta primeira
entrega, a aplicação usa HTTP e não possui autenticação; HTTPS e controle de
acesso estão registrados como melhorias futuras.

## Funcionalidades

- cadastrar, listar, consultar, editar e excluir livros;
- alterar a situação entre `Quero ler`, `Lendo` e `Lido`;
- buscar por título ou autor e filtrar por situação;
- registrar categoria, ISBN, avaliação e anotações;
- impedir ISBN duplicado e validar os dados recebidos;
- verificar API e conexão com o banco em `/api/health`;
- explorar e testar os endpoints em `/api/docs`.

## Arquitetura executável

```text
Navegador -> frontend (Nginx :80) -> backend (FastAPI :8000) -> database (MySQL :3306)
                    único público            rede interna              rede interna + volume
```

Os três serviços são separados. Somente a porta do frontend é publicada. Há
uma rede `edge` entre frontend e backend e uma rede interna `data` entre
backend e MySQL. O frontend não participa da rede do banco.

## Executar com Docker Compose

Pré-requisitos: Docker Engine e o plugin Docker Compose.

```bash
cp .env.example .env
```

Edite `.env`, defina uma senha forte e execute:

```bash
docker compose up -d --build
docker compose ps
```

Acesse:

- aplicação: `http://localhost` (ou a porta definida em `APP_PORT`);
- documentação REST: `http://localhost/api/docs`;
- saúde da API e banco: `http://localhost/api/health`.

Para acompanhar os logs:

```bash
docker compose logs -f --tail=100
```

Para parar sem apagar os dados:

```bash
docker compose down
```

> Não use `docker compose down -v` no ambiente de demonstração: a opção `-v`
> remove o volume do MySQL e, portanto, os dados.

## Imagens Docker e versão implantada

A cada merge na `main`, o pipeline publica as duas imagens no GHCR marcadas com
o SHA do commit que as originou:

- `ghcr.io/fburigo/mensal01-backend:<sha>`
- `ghcr.io/fburigo/mensal01-frontend:<sha>`

Pull Requests constroem as imagens para validar os Dockerfiles, mas não
publicam nada. A publicação só ocorre depois que os testes e as verificações
das duas imagens passam.

A versão implantada aparece na tag da imagem, em
`/api/version` (backend), em `/version.json` (frontend) e no rodapé da página,
que mostra os dois valores lado a lado.

Para baixar e conferir as imagens publicadas — na VM ou em qualquer máquina:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u SEU_USUARIO --password-stdin
./scripts/verificar-imagem-publicada.sh <sha-do-commit>
```

Para construir e verificar as imagens localmente:

```bash
SHA="$(git rev-parse HEAD)"
docker build -t mensal01-backend:local  --build-arg APP_VERSION="$SHA" ./backend
docker build -t mensal01-frontend:local --build-arg APP_VERSION="$SHA" ./frontend

./scripts/smoke-backend.sh  mensal01-backend:local  "$SHA"
./scripts/smoke-frontend.sh mensal01-frontend:local "$SHA"
```

O primeiro script confere que `/api/version`, o rótulo da imagem e a variável
`APP_VERSION` apontam para o mesmo commit. O segundo sobe a imagem do frontend
sozinha (sem o backend) e confere estáticos, versão, cabeçalhos de segurança, o
proxy `/api` e a ausência de segredos na imagem.

## Integração contínua

Todo Pull Request para `main` executa a pipeline definida em
`.github/workflows/pipeline.yml`. Antes de permitir a publicação das imagens,
ela executa:

1. Ruff e verificação de formatação;
2. auditoria das dependências Python com `pip-audit`;
3. pytest com relatório JUnit;
4. validação do Docker Compose com credenciais temporárias;
5. subida de frontend, backend e MySQL em ambiente descartável;
6. testes HTTP da API e testes de integração/persistência;
7. smoke tests das imagens do backend e frontend.

Os relatórios JUnit, API e integração são publicados como artifacts. Em caso
de falha do ambiente Docker, a pipeline também publica o estado e os logs dos
containers. O ambiente temporário é removido ao final, inclusive quando um
teste falha.

Para rodar a aplicação inteira com a versão identificada:

```bash
APP_VERSION="$(git rev-parse HEAD)" docker compose up -d --build
curl http://localhost/api/version
```

## API REST

| Método | Rota | Finalidade |
|---|---|---|
| `GET` | `/api/health` | verificar API e banco |
| `GET` | `/api/version` | consultar a versão implantada (SHA do commit) |
| `GET` | `/api/books` | listar, buscar e filtrar livros |
| `GET` | `/api/books/{id}` | consultar um livro |
| `POST` | `/api/books` | cadastrar um livro |
| `PUT` | `/api/books/{id}` | substituir os dados de um livro |
| `PATCH` | `/api/books/{id}/status` | alterar somente a situação |
| `DELETE` | `/api/books/{id}` | excluir um livro |

Exemplo de cadastro:

```bash
curl -i -X POST http://localhost/api/books \
  -H 'Content-Type: application/json' \
  -d '{"title":"O Hobbit","author":"J. R. R. Tolkien","category":"Fantasia","reading_status":"LENDO","rating":5}'
```

## Testes do backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
pytest -q
```

Os testes cobrem o ciclo REST completo, conflito de ISBN, validação de nota e
conexão com o banco. No ambiente real, valide também a persistência reiniciando
os containers, conforme [docs/EVIDENCIAS.md](docs/EVIDENCIAS.md).

## Testes de ponta a ponta (Windows, Linux e macOS)

Com os três containers no ar (`docker compose up -d`), dois scripts em Python
puro (sem dependências extras) validam a aplicação real pelo HTTP e pelo
Docker — funcionam em qualquer sistema operacional com Python 3.7+:

```bash
python3 test_api.py          # valida a API: Swagger, health check, CRUD
                              # completo, ISBN duplicado, dados inválidos
python3 test_integracao.py   # valida redes, proxy /api, health checks e
                              # volume/persistência (reinicia os containers)
```

(no Windows, use `python` em vez de `python3`.) Se a aplicação não estiver em
`http://localhost`, use `--base-url`, por exemplo
`python3 test_api.py --base-url http://SEU_IP`.

Cada script termina mostrando um resumo do que passou/falhou e espera Enter
antes de fechar, e gera um relatório em Markdown (`relatorio-testes-api.md` e
`relatorio-integracao.md`) com o resumo, o log de cada teste e o log bruto
completo da execução — evidência para os cartões "Finalizar backend e banco
MySQL" e "Integrar os três containers separados" do [Kanban](docs/KANBAN.md).
Ambos são seguros para rodar mais de uma vez: usam um sufixo com data/hora nos
dados de teste e apagam o que criam.

## Documentos da entrega

- [Arquitetura e decisões técnicas](docs/ARQUITETURA.md)
- [Diagrama em SVG](docs/arquitetura-cloud.svg)
- [Kanban mínimo para dois dias](docs/KANBAN.md)
- [Relatório de andamento](docs/RELATORIO.md)
- [Evidências e teste de persistência](docs/EVIDENCIAS.md)
- [Roteiro da apresentação](docs/ROTEIRO-APRESENTACAO.md)
- [Guia de implantação no GCP](docs/DEPLOY-GCP.md)
- [Cartão das imagens Docker](docs/CARTAO-IMAGENS-DOCKER.md)
- [Evidências das imagens Docker](docs/EVIDENCIAS-IMAGENS-DOCKER.md)

Antes da entrega, confira se os links públicos, o Kanban e o relatório continuam
correspondendo ao estado verdadeiro do grupo.

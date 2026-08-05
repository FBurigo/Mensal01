# Estante — Gerenciador de Biblioteca Pessoal

Aplicação Web acadêmica para cadastrar e acompanhar livros de uma biblioteca
pessoal. O projeto foi pensado para a primeira entrega de Cloud: simples de
demonstrar, com frontend, backend e banco de dados executados em serviços
separados e com persistência.

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

## API REST

| Método | Rota | Finalidade |
|---|---|---|
| `GET` | `/api/health` | verificar API e banco |
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

## Documentos da entrega

- [Arquitetura e decisões técnicas](docs/ARQUITETURA.md)
- [Diagrama em SVG](docs/arquitetura-cloud.svg)
- [Kanban mínimo para dois dias](docs/KANBAN.md)
- [Relatório de andamento](docs/RELATORIO.md)
- [Evidências e teste de persistência](docs/EVIDENCIAS.md)
- [Roteiro da apresentação](docs/ROTEIRO-APRESENTACAO.md)
- [Guia de implantação no GCP](docs/DEPLOY-GCP.md)

Antes da entrega, substitua os campos `NOME DO ...` nos documentos, inclua os
links reais e atualize o relatório com o estado verdadeiro do grupo.

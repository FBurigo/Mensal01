# Evidências e validação final

## Evidências da publicação no GCP

| Arquivo | O que comprova |
|---|---|
| [`01-aplicacao-publicada.png`](evidencias/01-aplicacao-publicada.png) | aplicação acessível pelo IP externo, dados carregados e registro identificado para o teste de persistência |
| [`02-health-check-publico.png`](evidencias/02-health-check-publico.png) | endpoint público `/api/health` com API ativa e banco conectado |
| [`03-swagger-api.png`](evidencias/03-swagger-api.png) | Swagger público com rotas `GET`, `POST`, `PUT`, `DELETE` e `PATCH` |
| [`04-containers-e-reinicio.png`](evidencias/04-containers-e-reinicio.png) | três containers saudáveis, reinício pelo Docker Compose e health check respondendo depois do reinício |
| [`09-demonstracao-crud.webm`](evidencias/09-demonstracao-crud.webm) | vídeo de 1min18s mostrando a aplicação pública, operações no CRUD, reinício dos containers e retorno dos dados |

As imagens comprovam a infraestrutura publicada e o reinício dos serviços. O
vídeo completa a evidência de persistência ao mostrar o livro identificado antes
e depois do reinício. Um print adicional da aplicação após o reinício pode ser
salvo como `evidencias/05-persistencia-apos-reinicio.png`, mas é opcional.

## Prints obrigatórios recomendados

1. aplicação aberta pela URL Cloud, com o endereço visível;
2. formulário de cadastro preenchido;
3. estante com pelo menos três livros e diferentes situações;
4. edição, filtro e mudança de situação funcionando;
5. Swagger em `/api/docs` com as rotas REST;
6. resposta de `/api/health` igual a `{"status":"ok","database":"connected"}`;
7. `docker compose ps` com três serviços separados e saudáveis;
8. teste de persistência antes e depois do reinício;
9. Kanban com as cinco colunas e histórico real de um cartão;
10. diagrama de arquitetura legível.

Oculte senhas, `.env`, chaves SSH, tokens, IP pessoal e quaisquer credenciais.

## Teste de persistência

Na VM, cadastre um livro identificável:

```bash
curl -sS -X POST http://localhost/api/books \
  -H 'Content-Type: application/json' \
  -d '{"title":"Evidência de persistência","author":"Equipe Estante","category":"Teste","reading_status":"LENDO"}'
```

Liste e registre o identificador:

```bash
curl -sS http://localhost/api/books
```

Reinicie sem remover volumes:

```bash
docker compose restart
docker compose ps
```

Consulte novamente:

```bash
curl -sS http://localhost/api/books
```

Critério: o registro `Evidência de persistência` deve continuar presente. Tire
prints com data e comandos, sem mostrar segredos.

## Capturas do CRUD pelo navegador

Para demonstrar as operações sem produzir prints demais:

1. clique no ícone de lápis de um livro e altere título, categoria, situação ou
   avaliação;
2. antes de salvar, capture o formulário preenchido como
   `evidencias/06-edicao-preenchida.png`;
3. salve e capture o cartão já atualizado como
   `evidencias/07-edicao-confirmada.png`;
4. use a busca e o filtro de situação e capture o resultado como
   `evidencias/08-busca-e-filtro.png`;
5. para exclusão, capture a caixa de confirmação aberta e depois confirme que o
   cartão desapareceu; evite excluir o livro usado na evidência de persistência.

Uma gravação contínua do CRUD também é válida e costuma demonstrar melhor as
transições entre cadastro, edição, mudança de situação e exclusão.

## Roteiro de vídeo de até cinco minutos

Vídeo gravado para a entrega:
[`09-demonstracao-crud.webm`](evidencias/09-demonstracao-crud.webm), com duração
de 1min18s, resolução 1920x1080 e tamanho aproximado de 7,7 MB.

- 0:00–0:25 — nome do projeto, integrantes e URL Cloud;
- 0:25–1:45 — cadastro, listagem, busca, filtro, edição, status e exclusão;
- 1:45–2:15 — Swagger e health check do banco;
- 2:15–3:00 — diagrama e separação frontend/backend/database;
- 3:00–3:35 — containers saudáveis e teste de persistência;
- 3:35–4:15 — Kanban e histórico real;
- 4:15–5:00 — segurança, limitações e próximos passos.

Grave em aba anônima para provar que a aplicação é pública e teste o link do
vídeo com uma conta que não pertence ao grupo.

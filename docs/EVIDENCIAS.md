# Evidências e validação final

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

## Roteiro de vídeo de até cinco minutos

- 0:00–0:25 — nome do projeto, integrantes e URL Cloud;
- 0:25–1:45 — cadastro, listagem, busca, filtro, edição, status e exclusão;
- 1:45–2:15 — Swagger e health check do banco;
- 2:15–3:00 — diagrama e separação frontend/backend/database;
- 3:00–3:35 — containers saudáveis e teste de persistência;
- 3:35–4:15 — Kanban e histórico real;
- 4:15–5:00 — segurança, limitações e próximos passos.

Grave em aba anônima para provar que a aplicação é pública e teste o link do
vídeo com uma conta que não pertence ao grupo.

# Roteiro da apresentação

## Divisão sugerida

### Product Owner — produto e escopo

- problema resolvido e público;
- funcionalidades priorizadas e critérios de aceite;
- demonstração do fluxo principal;
- o que ficou fora desta primeira entrega.

### Dev 2 — frontend e integração

- organização da interface e responsividade;
- consumo dos métodos REST;
- Nginx, proxy `/api` e tratamento de erros;
- evidências e testes de tela.

### Dev 1 — backend, banco e containers

- endpoints, códigos HTTP e validações;
- MySQL, migration, volume e prova de persistência;
- separação dos três containers e das redes;
- health checks, logs e comandos de diagnóstico.

### Bruno — Scrum Master, Cloud e processo

- arquitetura no GCP e justificativas;
- segurança, limitações e melhorias;
- evolução real do Kanban, cerimônias e impedimentos;
- próximos passos e checklist da entrega.

## Perguntas que todos devem saber responder

1. Por que há três serviços separados se todos estão na mesma VM?
2. Por que somente a porta 80 está pública?
3. Qual a diferença entre Nginx, backend e MySQL?
4. Como o volume preserva dados quando o container reinicia?
5. Por que não há Load Balancer nesta entrega?
6. O que `POST`, `GET`, `PUT`, `PATCH` e `DELETE` fazem no projeto?
7. Por que a API usa 201, 204, 404, 409 e 422?
8. Quais riscos existem sem HTTPS e autenticação?
9. O que muda se a única VM falhar?
10. Como Backlog, Aprovado, Em andamento, Em testes e Finalizado funcionam?
11. Qual é a responsabilidade do PO e do Scrum Master?
12. Quais cerimônias Scrum o grupo realizou e quais decisões surgiram delas?

## Respostas curtas essenciais

- Separação: cada camada tem responsabilidade e rede próprias; pode ser
  atualizada independentemente.
- Porta pública: o Nginx é o ponto de entrada e reduz a superfície de ataque.
- Persistência: os arquivos do MySQL ficam no volume, fora do filesystem
  descartável do container.
- Sem balanceador: há uma única instância; balancear não criaria alta
  disponibilidade e aumentaria custo.
- `PUT` x `PATCH`: PUT substitui os dados do livro; PATCH altera apenas o status.
- Scrum Master: facilita o processo e remove impedimentos; PO prioriza e aceita
  valor de produto; desenvolvedores entregam o incremento.

## Checklist antes de apresentar

- abrir aplicação, Swagger, Kanban e repositório em aba anônima;
- confirmar `/api/health` e os três containers saudáveis;
- preparar três livros de demonstração;
- fechar abas com senhas ou consoles sensíveis;
- deixar o diagrama aberto e legível;
- cronometrar a fala de cada integrante;
- ter vídeo e prints como plano de contingência.

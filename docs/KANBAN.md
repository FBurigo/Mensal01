# Kanban mínimo — entrega em 2 dias

Não criem mais cartões do que estes oito. Todos começam em `Backlog` e só são
movidos quando o trabalho realmente mudar de estado; assim, a própria ferramenta
gera o histórico exigido pela avaliação.

## Colunas obrigatórias

`Backlog` → `Aprovado` → `Em andamento` → `Em testes` → `Finalizado`

Cada cartão deve ter: título, descrição, responsável, prioridade e um comentário
com a evidência final (commit, print, teste ou link). A movimentação na ferramenta
será o histórico. Não inventem datas anteriores.

## Dia 1 — deixar a aplicação pronta

### 1. Organizar escopo e Kanban

- Descrição: criar as cinco colunas, cadastrar estes oito cartões e confirmar
  que o escopo é somente biblioteca pessoal com CRUD e status de leitura.
- Responsável: Bruno — Scrum Master.
- Apoio: Product Owner.
- Prioridade: Crítica.
- Aceite: quadro acessível, responsáveis definidos e sem funcionalidades extras.

### 2. Finalizar backend e banco MySQL

- Descrição: validar migration, modelo Livro e endpoints `GET`, `POST`, `PUT`,
  `PATCH` e `DELETE`.
- Responsável: Dev 1 — Backend/Database.
- Prioridade: Crítica.
- Aceite: Swagger funciona, dados inválidos são rejeitados e ISBN não duplica.

### 3. Finalizar frontend e consumo REST

- Descrição: validar cadastro, listagem, edição, status, exclusão, busca e filtro
  pelo navegador.
- Responsável: Dev 2 — Frontend.
- Prioridade: Crítica.
- Aceite: fluxo completo funciona em desktop e celular sem erro crítico.

### 4. Integrar os três containers separados

- Descrição: subir `frontend`, `backend` e `database`, verificar redes, proxy
  `/api`, health checks e volume.
- Responsável: Dev 1.
- Apoio: Dev 2.
- Prioridade: Crítica.
- Aceite: `docker compose ps` mostra três serviços saudáveis e somente a porta
  do frontend está pública.

## Dia 2 — publicar e entregar

### 5. Testar CRUD e persistência

- Descrição: executar o fluxo completo, cadastrar um livro, reiniciar os
  containers e confirmar que o registro permaneceu.
- Responsável: Product Owner.
- Apoio: Dev 1 e Dev 2.
- Prioridade: Crítica.
- Aceite: PO aprova o fluxo e anexa prints de antes/depois do reinício.

### 6. Publicar a aplicação no GCP

- Descrição: configurar a VM, `.env`, firewall HTTP e subir o Docker Compose.
- Responsável: Bruno — Scrum Master.
- Apoio: Dev 1.
- Prioridade: Crítica.
- Aceite: aplicação e `/api/health` abrem pelo IP público em aba anônima; portas
  8000 e 3306 não estão expostas.

### 7. Finalizar arquitetura e relatório

- Descrição: revisar diagrama, justificativas, segurança, limitações, andamento,
  integrantes e papéis.
- Responsável: Product Owner.
- Apoio: Bruno.
- Prioridade: Alta.
- Aceite: documentos correspondem ao sistema publicado e todos os nomes/links
  foram preenchidos.

### 8. Produzir evidências e fazer a entrega

- Descrição: tirar prints ou gravar vídeo, ensaiar rapidamente e conferir todos
  os links da Blackboard.
- Responsável: Dev 2.
- Apoio: equipe inteira.
- Prioridade: Crítica.
- Aceite: repositório, aplicação, arquitetura, diagrama, evidências, Kanban e
  relatório abrem sem login da equipe; todos sabem explicar sua parte.

## Divisão objetiva da equipe

| Pessoa | O que faz nestes dois dias |
|---|---|
| Bruno — Scrum Master | mantém o Kanban, remove bloqueios, coordena o deploy GCP, controla o checklist e ensaio |
| Product Owner | mantém o escopo mínimo, aceita o CRUD, valida persistência e fecha o relatório |
| Dev 1 | valida backend, MySQL, containers, logs, volume e ajuda no deploy |
| Dev 2 | valida frontend, integração, responsividade e produz prints/vídeo |

## Ordem real de movimentação

1. Bruno cria os oito itens em `Backlog`.
2. O PO move os itens do Dia 1 para `Aprovado`.
3. Cada responsável move apenas seu item para `Em andamento` ao começar.
4. Ao terminar, anexa a evidência e move para `Em testes`.
5. O PO testa e move para `Finalizado`; se falhar, devolve para `Em andamento`.
6. No Dia 2, repitam o mesmo fluxo com os quatro itens restantes.

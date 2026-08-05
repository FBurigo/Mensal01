# Relatório de andamento do projeto Estante

> Atualizar este documento na véspera da entrega. Não marcar como concluído o
> que ainda não foi validado pela equipe no ambiente Cloud.

## 1. Identificação da equipe

| Integrante | Papel principal | Responsabilidades |
|---|---|---|
| Bruno de Oliveira | Scrum Master | processo, impedimentos, Kanban, riscos, apresentação e entrega |
| NOME DO PO | Product Owner | visão, prioridades, critérios de aceite e validação |
| NOME DO DEV 1 | Desenvolvedor Backend/Database | API, MySQL, migrations, testes e deploy |
| NOME DO DEV 2 | Desenvolvedor Frontend/Integração | interface, integração REST, Nginx, testes de tela e evidências |

O grupo trabalha de forma colaborativa: os responsáveis lideram seus itens, mas
revisões, testes e conhecimento da arquitetura são compartilhados.

## 2. Objetivo do produto

Permitir que uma pessoa organize uma biblioteca particular, registre seus
livros e acompanhe o andamento das leituras em uma aplicação Web simples,
acessível pelo navegador e publicada em Cloud.

## 3. Funcionalidades implementadas no código

- cadastro de livro com título, autor, ISBN, categoria, situação, nota e notas;
- listagem e consulta individual;
- edição completa e alteração rápida da situação;
- exclusão com confirmação;
- busca por título/autor e filtro por situação;
- indicadores de total, lendo e concluídos;
- validação de campos, ISBN único e mensagens de erro;
- documentação OpenAPI/Swagger e health check da API/banco;
- migration do MySQL e volume persistente;
- containers separados para frontend, backend e database;
- testes automatizados do ciclo REST.

## 4. Em desenvolvimento ou aguardando validação

- execução dos testes automatizados no computador de um integrante;
- validação integrada dos três containers com Docker Compose;
- publicação na VM do Google Compute Engine;
- configuração final de firewall e variáveis secretas;
- teste de persistência após reinício no ambiente Cloud;
- produção de prints/vídeo e criação do quadro na ferramenta escolhida;
- ensaio técnico com os quatro integrantes.

## 5. Dificuldades encontradas

- equilibrar separação entre camadas e baixo custo de infraestrutura;
- manter banco e API protegidos sem impedir a comunicação interna;
- garantir que a aplicação inicial seja pequena, mas demonstre REST e
  persistência de forma completa;
- coordenar atividades para que o histórico do Kanban represente trabalho real;
- planejar publicação em uma VM com memória limitada.

Soluções adotadas: containers independentes, duas redes Docker, apenas o Nginx
público, stack leve em Python/JavaScript, health checks e escopo sem autenticação
ou funcionalidades secundárias nesta entrega.

## 6. Próximos passos

1. todos revisarem o repositório e criarem os cartões do Kanban;
2. executar testes, corrigir defeitos encontrados e registrar evidências;
3. publicar os três serviços na VM e validar a URL externamente;
4. executar e gravar o teste de persistência;
5. revisar arquitetura, segurança, limitações e Scrum em grupo;
6. concluir evidências, relatório e checklist da Blackboard;
7. planejar HTTPS, autenticação, backup e CI/CD para a próxima etapa.

## 7. Estado da infraestrutura

- Cloud escolhida: Google Cloud Platform;
- computação planejada: uma VM do Compute Engine;
- orquestração local: Docker Compose;
- componentes: Nginx/frontend, FastAPI/backend e MySQL/database;
- persistência: volume `mysql_data`;
- balanceador: não utilizado nesta etapa;
- CI/CD: fora do escopo desta entrega, conforme o enunciado.

## 8. Links da entrega

- Repositório Git: `PREENCHER`
- Aplicação publicada: `PREENCHER`
- Quadro Kanban: `PREENCHER`
- Evidências/vídeo: `PREENCHER`
- Documento e diagrama: disponíveis na pasta `docs/` do repositório

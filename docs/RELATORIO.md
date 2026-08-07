# Relatório de andamento do projeto Estante

Este relatório registra o estado validado da primeira entrega em Cloud.

## 1. Identificação da equipe

| Integrante | Papel principal | Responsabilidades |
|---|---|---|
| Bruno de Oliveira | Scrum Master | processo, impedimentos, Kanban, riscos, apresentação e entrega |
| Felipe Burigo | Product Owner | visão, prioridades, critérios de aceite e validação |
| Felipe Vidal | Desenvolvedor Backend/Database | API, MySQL, migrations, testes e deploy |
| Eduardo | Desenvolvedor Frontend/Integração | interface, integração REST, Nginx, testes de tela e evidências |

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

## 4. Funcionalidades e infraestrutura concluídas

- testes automatizados da API executados com 14 de 14 verificações aprovadas;
- integração executada com 8 de 8 verificações aprovadas;
- três containers separados e saudáveis pelo Docker Compose;
- aplicação publicada e acessível pelo IP externo da VM;
- frontend e Swagger acessíveis pelo navegador;
- endpoint `/api/health` confirmando API ativa e banco conectado;
- somente a porta 80 publicada, mantendo backend e MySQL sem portas externas;
- CRUD validado pelo navegador;
- persistência validada após reinício dos containers;
- prints e vídeo de evidência armazenados no repositório.

Permanece como atividade organizacional o ensaio técnico final com todos os
integrantes e a conferência dos links enviados na Blackboard.

## 5. Dificuldades encontradas

- equilibrar separação entre camadas e baixo custo de infraestrutura;
- manter banco e API protegidos sem impedir a comunicação interna;
- garantir que a aplicação inicial seja pequena, mas demonstre REST e
  persistência de forma completa;
- coordenar atividades para que o histórico do Kanban represente trabalho real;
- planejar publicação em uma VM com memória limitada.
- sincronizar a inicialização do backend com o momento em que o MySQL passa a
  aceitar conexões durante a primeira subida dos containers.

Soluções adotadas: containers independentes, duas redes Docker, apenas o Nginx
público, stack leve em Python/JavaScript, health checks e escopo sem autenticação
ou funcionalidades secundárias nesta entrega.

## 6. Próximos passos

1. concluir o histórico real dos cartões restantes no Kanban;
2. conferir os links e arquivos enviados na Blackboard;
3. ensaiar arquitetura, segurança, limitações e Scrum com todo o grupo;
4. manter a VM disponível durante o período de avaliação;
5. planejar HTTPS, autenticação, backup automatizado e CI/CD para a próxima etapa.

## 7. Estado da infraestrutura

- Cloud escolhida: Google Cloud Platform;
- computação publicada: uma VM do Compute Engine;
- orquestração local: Docker Compose;
- componentes: Nginx/frontend, FastAPI/backend e MySQL/database;
- persistência: volume `mysql_data`;
- balanceador: não utilizado nesta etapa;
- CI/CD: fora do escopo desta entrega, conforme o enunciado.
- endereço público validado: `http://35.238.205.240/`;
- limitações conhecidas: VM única, HTTP e aplicação sem autenticação.

## 8. Links da entrega

- Repositório Git: <https://github.com/FBurigo/Mensal01>
- Aplicação publicada: <http://35.238.205.240/>
- Quadro Kanban: <https://github.com/users/FBurigo/projects/2>
- Evidências/vídeo: <https://github.com/FBurigo/Mensal01/tree/main/docs/evidencias>
- Documento técnico: <https://github.com/FBurigo/Mensal01/blob/main/docs/ARQUITETURA.md>
- Diagrama: <https://github.com/FBurigo/Mensal01/blob/main/docs/arquitetura-cloud.svg>

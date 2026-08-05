# Guia de implantação no Google Cloud

## Arquitetura da primeira entrega

Use uma VM Ubuntu no Compute Engine. Dentro dela, execute o `compose.yaml`, que
cria três containers separados. Publique somente a porta 80 do frontend. Não
crie regras de firewall para 8000 ou 3306.

Uma `e2-micro` pode servir para teste de baixo tráfego, mas possui 1 GB de
memória e CPU compartilhada. Antes da apresentação, monitore a VM; se houver
travamentos, use uma `e2-small` (2 GB) ou `e2-medium` (4 GB). Uma única VM
continua sendo ponto único de falha.

Na consulta realizada em 5 de agosto de 2026, o Free Tier inclui uso elegível
de uma `e2-micro` não preemptível em `us-west1`, `us-central1` ou `us-east1` e
30 GB-mês de Persistent Disk padrão. Isso não torna todos os recursos gratuitos:
IP, tráfego, snapshots ou uso fora dos limites podem gerar cobrança. Confirme
novamente no momento da criação.

## Preparação

1. criar a VM Ubuntu e reservar um IP externo estático se a URL não puder mudar;
2. restringir SSH ao necessário e permitir HTTP na porta 80;
3. instalar Docker Engine e o plugin Compose pelo repositório oficial do Docker;
4. clonar o repositório na VM;
5. copiar `.env.example` para `.env` e trocar a senha;
6. subir e verificar a aplicação.

```bash
cp .env.example .env
nano .env
docker compose up -d --build
docker compose ps
curl -i http://localhost/api/health
```

Não versionar `.env`. Para evitar exposição pelo histórico do shell, a equipe
pode editar o arquivo diretamente em vez de colocar a senha no comando.

## Diagnóstico

```bash
docker compose ps
docker compose logs --tail=100 frontend
docker compose logs --tail=100 backend
docker compose logs --tail=100 database
free -h
df -h
```

Condições esperadas:

- os três serviços aparecem como saudáveis;
- `http://IP_DA_VM/` abre a interface;
- `http://IP_DA_VM/api/docs` abre o Swagger;
- `/api/health` informa que o banco está conectado;
- as portas 8000 e 3306 não respondem externamente.

## Atualização manual nesta etapa

Como CI/CD não é avaliado agora, uma atualização controlada pode ser feita com:

```bash
git pull --ff-only
docker compose up -d --build
docker compose ps
```

Antes de atualizar no dia da apresentação, registre uma versão estável e tenha
prints/vídeo de contingência. Não execute comandos que removam o volume.

## Backup mínimo antes da apresentação

```bash
docker compose exec -T database sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mysqldump -u"$MYSQL_USER" "$MYSQL_DATABASE"' > biblioteca-backup.sql
```

Proteja o arquivo, pois ele contém os dados da aplicação. Para um uso real, o
backup deve ser automatizado, armazenado fora da VM e ter restauração testada.

## Fontes oficiais consultadas

- [Free Tier do Google Cloud](https://docs.cloud.google.com/free/docs/free-cloud-features?hl=pt)
- [Tipos de máquina E2 do Compute Engine](https://docs.cloud.google.com/compute/docs/general-purpose-machines)
- [Instalação do Docker Engine no Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Regras de firewall da VPC](https://docs.cloud.google.com/firewall/docs/using-firewalls)
- [MySQL 8.4 com containers Docker](https://dev.mysql.com/doc/refman/8.4/en/linux-installation-docker.html)

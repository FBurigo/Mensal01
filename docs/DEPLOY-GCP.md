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

## Atualização automática

O repositório GitHub contém somente metadados não secretos. O environment
`production` é criado automaticamente na primeira execução do job e registra
o histórico dos deployments:

| Variável | Finalidade |
|---|---|
| `GCP_PROJECT_ID` | projeto que contém a VM e o pool de identidades |
| `GCP_WIF_PROVIDER` | nome completo do provider OIDC |
| `GCP_SERVICE_ACCOUNT` | conta de serviço exclusiva do deploy |
| `GCP_ZONE` | zona da VM |
| `GCP_VM_NAME` | nome da instância |
| `GCP_VM_IP` | endereço exibido no histórico do deployment |
| `GCP_DEPLOY_PATH` | diretório absoluto que já contém o `.env` de produção |

O GitHub troca o token OIDC do job por credenciais curtas da GCP. A confiança
é limitada ao repositório `FBurigo/Mensal01`; nenhuma chave JSON de conta de
serviço é criada ou armazenada.

Após os jobs de qualidade, integração, imagens e publicação, o job
`deploy-production`:

1. envia `compose.yaml`, `compose.production.yaml` e o script de deploy à VM;
2. registra a versão ativa e o identificador do volume MySQL;
3. cria em `/var/backups/mensal01` um dump compactado e seu SHA-256;
4. informa o SHA aprovado em `APP_VERSION`;
5. baixa backend e frontend do GHCR pela tag imutável do SHA;
6. executa `docker compose up -d --no-build --wait`;
7. confirma o mesmo volume e que 8000/3306 continuam privadas;
8. valida frontend, banco, proxy `/api` e o SHA de `/api/version`;
9. publica aprovação, diagnóstico ou rollback no GitHub Actions.

O script nunca executa `docker compose down -v`. Se a candidata falhar, ele
coleta `docker compose ps` e logs, restaura as imagens da versão registrada,
repete saúde/versão/volume e mantém o job com resultado falho mesmo quando a
recuperação funciona. O backup não é restaurado automaticamente porque o volume
é preservado; ele fica disponível para recuperação manual de banco, evitando
sobrescrever dados gravados durante a janela de deploy.

## Drill seguro de rollback

Em **Actions → CI/CD - Biblioteca Pessoal → Run workflow**, selecione a `main` e
marque `rollback_drill`. O workflow valida o commit atual, implanta a mesma tag e
força uma rejeição após a validação. O rollback restaura e valida a versão
anterior, mas o job termina falho de propósito para registrar a evidência.

Para diagnóstico manual, reproduza na VM sem reconstruir imagens:

```bash
sudo bash scripts/deploy-production.sh <sha-de-40-caracteres> "$(pwd)"
```

## Backup manual adicional

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
- [Workload Identity Federation para pipelines](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)
- [Autenticação Google para GitHub Actions](https://github.com/google-github-actions/auth)

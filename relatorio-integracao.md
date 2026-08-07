# Relatório de integração dos containers - Biblioteca Pessoal

Gerado em: 2026-08-06 21:47:59
Projeto Compose: `biblioteca-pessoal`

**Resultado geral: 8 / 8 checagens OK**

## Resumo

| # | Checagem | Esperado | Obtido | Resultado |
|---|---|---|---|---|
| 1 | Rede 'edge' conecta frontend e backend | contém biblioteca-pessoal-frontend-1 e biblioteca-pessoal-backend-1 | biblioteca-pessoal-frontend-1 biblioteca-pessoal-backend-1 | OK |
| 2 | Rede 'data' conecta backend e database (sem frontend) | contém biblioteca-pessoal-backend-1 e biblioteca-pessoal-database-1, NÃO contém biblioteca-pessoal-frontend-1 | biblioteca-pessoal-database-1 biblioteca-pessoal-backend-1 | OK |
| 3 | Rede 'data' é interna (isolada, sem saída) | true | true | OK |
| 4 | Proxy /api do frontend para o backend | 200, header Server: nginx, database:connected | ver log | OK |
| 5 | Somente a porta do frontend está publicada no host | frontend com porta mapeada; backend e database sem porta publicada | frontend=[80/tcp -> 0.0.0.0:80
80/tcp -> [::]:80] backend=[] database=[] | OK |
| 6 | Os 3 serviços estão 'healthy' | healthy nos 3 | frontend=healthy backend=healthy database=healthy | OK |
| 7 | Volume do MySQL existe | volume biblioteca-pessoal_mysql_data existe | biblioteca-pessoal_mysql_data: /var/lib/docker/volumes/biblioteca-pessoal_mysql_data/_data | OK |
| 8 | Persistência do volume (cadastro sobrevive a docker compose restart) | livro 'Evidencia de persistencia 20260806214743' continua existindo e os 3 containers voltam healthy | ver log | OK |

## Log detalhado por checagem

### 1. Rede 'edge' conecta frontend e backend — OK

- Esperado: contém biblioteca-pessoal-frontend-1 e biblioteca-pessoal-backend-1
- Obtido: biblioteca-pessoal-frontend-1 biblioteca-pessoal-backend-1
- Log:

```text
docker network inspect biblioteca-pessoal_edge --format ...
biblioteca-pessoal-frontend-1 biblioteca-pessoal-backend-1
```

### 2. Rede 'data' conecta backend e database (sem frontend) — OK

- Esperado: contém biblioteca-pessoal-backend-1 e biblioteca-pessoal-database-1, NÃO contém biblioteca-pessoal-frontend-1
- Obtido: biblioteca-pessoal-database-1 biblioteca-pessoal-backend-1
- Log:

```text
docker network inspect biblioteca-pessoal_data --format ...
biblioteca-pessoal-database-1 biblioteca-pessoal-backend-1
```

### 3. Rede 'data' é interna (isolada, sem saída) — OK

- Esperado: true
- Obtido: true
- Log:

```text
docker network inspect biblioteca-pessoal_data --format "{{.Internal}}"
true
```

### 4. Proxy /api do frontend para o backend — OK

- Esperado: 200, header Server: nginx, database:connected
- Obtido: ver log
- Log:

```text
GET http://localhost/api/health
Status: 200
Server: nginx
Corpo: {"status":"ok","database":"connected"}
```

### 5. Somente a porta do frontend está publicada no host — OK

- Esperado: frontend com porta mapeada; backend e database sem porta publicada
- Obtido: frontend=[80/tcp -> 0.0.0.0:80
80/tcp -> [::]:80] backend=[] database=[]
- Log:

```text
docker port biblioteca-pessoal-frontend-1
80/tcp -> 0.0.0.0:80
80/tcp -> [::]:80

docker port biblioteca-pessoal-backend-1


docker port biblioteca-pessoal-database-1

```

### 6. Os 3 serviços estão 'healthy' — OK

- Esperado: healthy nos 3
- Obtido: frontend=healthy backend=healthy database=healthy
- Log:

```text
docker inspect biblioteca-pessoal-frontend-1 --format ... -> healthy
docker inspect biblioteca-pessoal-backend-1 --format ... -> healthy
docker inspect biblioteca-pessoal-database-1 --format ... -> healthy
```

### 7. Volume do MySQL existe — OK

- Esperado: volume biblioteca-pessoal_mysql_data existe
- Obtido: biblioteca-pessoal_mysql_data: /var/lib/docker/volumes/biblioteca-pessoal_mysql_data/_data
- Log:

```text
docker volume inspect biblioteca-pessoal_mysql_data --format ...
biblioteca-pessoal_mysql_data: /var/lib/docker/volumes/biblioteca-pessoal_mysql_data/_data
```

### 8. Persistência do volume (cadastro sobrevive a docker compose restart) — OK

- Esperado: livro 'Evidencia de persistencia 20260806214743' continua existindo e os 3 containers voltam healthy
- Obtido: ver log
- Log:

```text
POST http://localhost/api/books -> 201, id=19

docker compose restart
Container biblioteca-pessoal-database-1 Restarting 
 Container biblioteca-pessoal-backend-1 Restarting 
 Container biblioteca-pessoal-frontend-1 Restarting 
 Container biblioteca-pessoal-frontend-1 Started 
 Container biblioteca-pessoal-database-1 Started 
 Container biblioteca-pessoal-backend-1 Started

Após restart -> frontend healthy=True, backend healthy=True, database healthy=True

GET http://localhost/api/books/19 -> 200
Corpo: {"title":"Evidencia de persistencia 20260806214743","author":"Script de integracao","isbn":null,"category":"Teste","reading_status":"LENDO","rating":null,"notes":null,"id":19,"created_at":"2026-08-07T00:47:43","updated_at":"2026-08-07T00:47:43"}
```

## Log completo da execução

Saída de console completa e sem edição, na ordem em que as checagens rodaram.

```text
Projeto Compose detectado: biblioteca-pessoal

======================================================================
CHECAGEM: Rede 'edge' conecta frontend e backend
Esperado: contém biblioteca-pessoal-frontend-1 e biblioteca-pessoal-backend-1
Obtido:   biblioteca-pessoal-frontend-1 biblioteca-pessoal-backend-1
--- log ---
docker network inspect biblioteca-pessoal_edge --format ...
biblioteca-pessoal-frontend-1 biblioteca-pessoal-backend-1
Resultado: OK
======================================================================

======================================================================
CHECAGEM: Rede 'data' conecta backend e database (sem frontend)
Esperado: contém biblioteca-pessoal-backend-1 e biblioteca-pessoal-database-1, NÃO contém biblioteca-pessoal-frontend-1
Obtido:   biblioteca-pessoal-database-1 biblioteca-pessoal-backend-1
--- log ---
docker network inspect biblioteca-pessoal_data --format ...
biblioteca-pessoal-database-1 biblioteca-pessoal-backend-1
Resultado: OK
======================================================================

======================================================================
CHECAGEM: Rede 'data' é interna (isolada, sem saída)
Esperado: true
Obtido:   true
--- log ---
docker network inspect biblioteca-pessoal_data --format "{{.Internal}}"
true
Resultado: OK
======================================================================

======================================================================
CHECAGEM: Proxy /api do frontend para o backend
Esperado: 200, header Server: nginx, database:connected
Obtido:   ver log
--- log ---
GET http://localhost/api/health
Status: 200
Server: nginx
Corpo: {"status":"ok","database":"connected"}
Resultado: OK
======================================================================

======================================================================
CHECAGEM: Somente a porta do frontend está publicada no host
Esperado: frontend com porta mapeada; backend e database sem porta publicada
Obtido:   frontend=[80/tcp -> 0.0.0.0:80
80/tcp -> [::]:80] backend=[] database=[]
--- log ---
docker port biblioteca-pessoal-frontend-1
80/tcp -> 0.0.0.0:80
80/tcp -> [::]:80

docker port biblioteca-pessoal-backend-1


docker port biblioteca-pessoal-database-1

Resultado: OK
======================================================================

======================================================================
CHECAGEM: Os 3 serviços estão 'healthy'
Esperado: healthy nos 3
Obtido:   frontend=healthy backend=healthy database=healthy
--- log ---
docker inspect biblioteca-pessoal-frontend-1 --format ... -> healthy
docker inspect biblioteca-pessoal-backend-1 --format ... -> healthy
docker inspect biblioteca-pessoal-database-1 --format ... -> healthy
Resultado: OK
======================================================================

======================================================================
CHECAGEM: Volume do MySQL existe
Esperado: volume biblioteca-pessoal_mysql_data existe
Obtido:   biblioteca-pessoal_mysql_data: /var/lib/docker/volumes/biblioteca-pessoal_mysql_data/_data
--- log ---
docker volume inspect biblioteca-pessoal_mysql_data --format ...
biblioteca-pessoal_mysql_data: /var/lib/docker/volumes/biblioteca-pessoal_mysql_data/_data
Resultado: OK
======================================================================
[biblioteca-pessoal-frontend-1] healthy (levou 0s)
[biblioteca-pessoal-backend-1] healthy (levou 5s)
[biblioteca-pessoal-database-1] healthy (levou 0s)

======================================================================
CHECAGEM: Persistência do volume (cadastro sobrevive a docker compose restart)
Esperado: livro 'Evidencia de persistencia 20260806214743' continua existindo e os 3 containers voltam healthy
Obtido:   ver log
--- log ---
POST http://localhost/api/books -> 201, id=19

docker compose restart
Container biblioteca-pessoal-database-1 Restarting 
 Container biblioteca-pessoal-backend-1 Restarting 
 Container biblioteca-pessoal-frontend-1 Restarting 
 Container biblioteca-pessoal-frontend-1 Started 
 Container biblioteca-pessoal-database-1 Started 
 Container biblioteca-pessoal-backend-1 Started

Após restart -> frontend healthy=True, backend healthy=True, database healthy=True

GET http://localhost/api/books/19 -> 200
Corpo: {"title":"Evidencia de persistencia 20260806214743","author":"Script de integracao","isbn":null,"category":"Teste","reading_status":"LENDO","rating":null,"notes":null,"id":19,"created_at":"2026-08-07T00:47:43","updated_at":"2026-08-07T00:47:43"}
Resultado: OK
======================================================================
```
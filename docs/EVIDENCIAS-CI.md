# Evidências — qualidade, testes e integração contínua

Esta página documenta a implementação da issue
[#12](https://github.com/FBurigo/Mensal01/issues/12).

## Fluxo implementado

```text
quality-and-unit-tests
  ├── Ruff
  ├── Ruff format --check
  ├── pip-audit
  └── pytest + JUnit artifact
          │
          ▼
integration-tests
  ├── docker compose config --quiet
  ├── ambiente temporário: frontend + backend + MySQL
  ├── /api/health
  ├── test_api.py
  ├── test_integracao.py
  ├── relatórios e logs como artifacts
  └── docker compose down -v
          │
          ├── backend-smoke
          └── frontend-smoke
                  │
                  ▼
        publicação no GHCR somente em push na main
```

## Isolamento do ambiente de CI

O job de integração define credenciais exclusivas e descartáveis no próprio
runner. Nenhum secret ou banco de produção é utilizado. A porta pública do
ambiente temporário é `8080`; backend e MySQL permanecem apenas nas redes do
Docker Compose.

O teardown usa `docker compose down -v --remove-orphans`. A remoção do volume é
intencional somente nesse runner efêmero. Esse comando não faz parte do deploy
de produção.

## Artifacts

- `junit-report-<run-id>`: resultado estruturado do pytest;
- `integration-reports-<run-id>`: relatórios Markdown da API e integração;
- em falhas: `docker-compose-ps.txt` e `docker-compose.log`.

## Evidências a registrar após o Pull Request

- [ ] Link do Pull Request
- [ ] Execução inicial da pipeline
- [ ] Execução corrigida e completa com sucesso
- [ ] Relatório JUnit
- [ ] Relatório dos testes da API
- [ ] Relatório dos testes de integração
- [ ] Logs coletados em uma execução com falha
- [ ] Revisão de outro integrante

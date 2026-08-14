# Evidências — implantação automática na GCP

Esta página acompanha a implementação da
[#14](https://github.com/FBurigo/Mensal01/issues/14).

## Fluxo

```text
push na main
  → qualidade, segurança e pytest
  → API, integração e MySQL temporário
  → smoke tests das imagens
  → publicação no GHCR por SHA
  → verificação das imagens publicadas
  → autenticação OIDC/WIF na GCP
  → deploy-production (concorrência: 1)
      → docker compose pull
      → docker compose up -d --no-build --wait
      → volume MySQL preservado
      → frontend + /api/health + /api/version + /api/books
```

## Controles de segurança

- OIDC/Workload Identity Federation substitui uma chave JSON permanente.
- A confiança aceita tokens somente do repositório `FBurigo/Mensal01`.
- O job executa somente após push na `main` e após a publicação aprovada.
- O ambiente `production` serializa os deploys e mantém o histórico no GitHub.
- Backend e MySQL usam somente redes Docker privadas, sem portas no host.
- O `.env` existente na VM não é enviado ao GitHub nem sobrescrito.
- Nenhum caminho de implantação executa `docker compose down -v`.

## Evidências a registrar após o merge

- [ ] Pull Request
- [ ] Execução completa do job `deploy-production`
- [ ] Histórico do environment `production`
- [ ] SHA implantado e imagens utilizadas
- [ ] Saída de `/api/health`
- [ ] Saída de `/api/version`
- [ ] Resultado do smoke test do frontend e proxy `/api`
- [ ] Identificador do volume MySQL antes e depois
- [ ] Confirmação de que 8000 e 3306 permanecem privadas
- [ ] Revisão de outro integrante

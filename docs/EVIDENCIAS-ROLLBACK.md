# Evidências — validação pós-deploy e rollback

Esta página acompanha a implementação da
[#15](https://github.com/FBurigo/Mensal01/issues/15).

## Decisão automática

```text
registrar versão e volume atuais
  → backup MySQL .sql.gz + SHA-256
  → baixar e subir imagens candidatas por SHA
  → aguardar containers saudáveis
  → validar frontend, banco, proxy, volume e /api/version
      ├── aprovado → manter candidata
      └── rejeitado
           → coletar ps e logs
           → restaurar imagens da versão anterior
           → validar novamente saúde, SHA e volume
           → manter o job como falho
```

## Segurança do drill

O input manual `rollback_drill` usa o SHA já publicado na `main`. A falha é
injetada somente após a candidata responder corretamente; nenhuma imagem
defeituosa é introduzida. A recuperação ainda executa todo o caminho real de
pull, `up -d --no-build`, saúde, versão e persistência.

## Evidências a registrar

- [ ] Pull Request
- [ ] Deploy normal aprovado
- [ ] Versão anterior e candidata
- [ ] Caminho, tamanho e checksum do backup
- [ ] Resultado de `/api/health`
- [ ] Comparação de `/api/version` com o SHA esperado
- [ ] Execução controlada com falha
- [ ] Logs do diagnóstico e do rollback
- [ ] Versão restaurada
- [ ] Volume MySQL preservado
- [ ] Job marcado como falho após a recuperação
- [ ] Comentário formal de aceite ou rejeição

# Cartão — Build e publicação das imagens Docker (GHCR)

## Objetivo

Gerar e publicar automaticamente as imagens Docker do backend e do frontend,
identificando cada artefato pelo SHA do commit que o originou. Os Dockerfiles
existentes devem ser reutilizados — este cartão não exige reconstruir a
arquitetura da primeira entrega.

## Prioridade

Crítica

## Dependência

Depende da pipeline de qualidade e testes estar funcionando.

## Responsáveis

### Eduardo

- Configurar o build e a publicação da imagem do frontend.
- Garantir o funcionamento do Nginx e do proxy `/api`.
- Verificar se a imagem publicada pode ser baixada e iniciada.

### Felipe Burigo

- Implementar a identificação da versão da aplicação.
- Configurar `APP_VERSION`.
- Disponibilizar o endpoint `/api/version`.
- Configurar o build e a publicação da imagem do backend.
- Verificar a associação entre imagem e commit.

## Checklist

- [ ] Configurar Docker Buildx
- [ ] Configurar autenticação no GHCR com `GITHUB_TOKEN`
- [ ] Configurar permissão `packages: write`
- [ ] Reutilizar o Dockerfile do backend
- [ ] Reutilizar o Dockerfile do frontend
- [ ] Criar a variável `APP_VERSION`
- [ ] Criar o endpoint `/api/version`
- [ ] Fazer `/api/version` retornar o SHA
- [ ] Construir a imagem do backend
- [ ] Construir a imagem do frontend
- [ ] Identificar as imagens pelo SHA do commit
- [ ] Publicar a imagem do backend no GHCR
- [ ] Publicar a imagem do frontend no GHCR
- [ ] Impedir publicação durante Pull Requests
- [ ] Publicar somente após sucesso dos testes
- [ ] Testar o download das imagens
- [ ] Garantir que `.env` e senhas não entrem nas imagens
- [ ] Registrar os links dos pacotes publicados

## Artefatos esperados

- `ghcr.io/fburigo/mensal01-backend:<sha>`
- `ghcr.io/fburigo/mensal01-frontend:<sha>`

## Critérios de aceite

- Pull Requests realizam build, mas não publicam imagens oficiais.
- Merge na `main` publica as duas imagens.
- Cada imagem possui uma tag associada ao SHA.
- A aplicação informa a versão implantada.
- As imagens podem ser baixadas pela VM.
- Nenhum segredo está presente nos artefatos.
- Falha nos testes impede a publicação.
- O Pull Request foi revisado por outro integrante.

## Evidências esperadas

- Link do Pull Request
- Logs dos builds
- Links das imagens no GHCR
- Tags publicadas
- Resposta de `/api/version`
- Evidência do download das imagens

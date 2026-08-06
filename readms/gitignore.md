# .gitignore

**Localização:** `/.gitignore`

## O que faz

Lista de padrões de arquivos e pastas que o Git deve ignorar (não versionar).

## O que é ignorado

| Padrão | Motivo |
|---|---|
| `.env` | Contém senhas e segredos — nunca deve ir ao repositório |
| `__pycache__/`, `*.py[cod]` | Bytecode Python gerado automaticamente |
| `.pytest_cache/`, `.coverage`, `htmlcov/` | Artefatos de testes e cobertura |
| `.venv/` | Ambiente virtual Python local |
| `.idea/`, `.vscode/` | Configurações de IDEs pessoais |
| `*.log` | Arquivos de log |

## Dependências

- Nenhuma — lido automaticamente pelo Git.

# backend/migrations/script.py.mako

**Localização:** `/backend/migrations/script.py.mako`

## O que faz

Template Mako usado pelo Alembic para gerar novos arquivos de migration automaticamente quando se roda `alembic revision`. Toda migration nova criada segue a estrutura deste template.

## Estrutura gerada pelo template

- Docstring com a mensagem da revision
- Metadados: `revision`, `down_revision`, `branch_labels`, `depends_on`
- Função `upgrade()`: código que aplica a migration (criar tabela, adicionar coluna, etc.)
- Função `downgrade()`: código que reverte a migration

## Dependências

- Alembic (processa o template automaticamente)
- Mako template engine (inclusa no Alembic)

## Quando é usado

Apenas ao rodar:
```bash
alembic revision -m "descricao"
# ou
alembic revision --autogenerate -m "descricao"
```

Nunca é executado diretamente.

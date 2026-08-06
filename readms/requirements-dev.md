# backend/requirements-dev.txt

**Localização:** `/backend/requirements-dev.txt`

## O que faz

Lista as dependências Python para ambiente de desenvolvimento e testes. Inclui tudo de `requirements.txt` mais ferramentas de teste.

## Dependências adicionais

| Pacote | Versão | Para que serve |
|---|---|---|
| `pytest` | `>=8.3, <9.0` | Framework de testes |
| `httpx` | `>=0.28, <1.0` | Cliente HTTP assíncrono — exigido pelo `TestClient` do FastAPI |

## Como instalar

```bash
cd backend
pip install -r requirements-dev.txt
```

## Como rodar os testes

```bash
cd backend
pytest tests/
```

## Quem usa este arquivo

- Desenvolvedor local ao rodar testes
- CI/CD pipeline (se configurado)
- **Não** é instalado na imagem Docker de produção

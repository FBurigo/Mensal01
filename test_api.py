#!/usr/bin/env python3
"""
Validação da API Biblioteca Pessoal (Swagger, health, CRUD completo,
validação de dados inválidos e ISBN duplicado). Funciona em Windows, Linux
e macOS -- só precisa de Python 3.7+, nenhuma dependência externa.

Uso:
    python3 test_api.py
    python3 test_api.py --base-url http://localhost

Pré-requisito: containers no ar (docker compose up -d) e app acessível
em http://localhost (ajuste com --base-url se usar outra porta/host).

Gera relatorio-testes-api.md na mesma pasta do script, com resumo, log de
requisição/resposta de cada teste e o log completo da execução.
"""

import argparse
import json
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
LOG_LINES = []


def log(msg=""):
    """Imprime no console e guarda para o log completo do relatório."""
    print(msg)
    LOG_LINES.append(str(msg))


def http_request(method, url, body=None):
    """Faz a requisição HTTP e devolve (status_code, corpo_texto)."""
    data = None
    headers = {}
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
        headers["Content-Type"] = "application/json; charset=utf-8"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status, resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode("utf-8", errors="replace")
    except urllib.error.URLError as exc:
        return 0, f"(falha de conexão: {exc.reason})"


def run_test(nome, method, url, body=None, esperado=200):
    inicio = datetime.now()
    codigo, resposta = http_request(method, url, body)
    duracao_ms = round((datetime.now() - inicio).total_seconds() * 1000)
    resultado = "OK" if codigo == esperado else "FALHOU"

    log("")
    log("=" * 70)
    log(f"TESTE: {nome}")
    log(f"Hora: {inicio.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
    log(f"Requisicao: {method} {url}")
    if body is not None:
        log(f"Corpo enviado: {json.dumps(body, ensure_ascii=False)}")
    log(f"Status esperado: {esperado} | Status obtido: {codigo} | Duracao: {duracao_ms}ms")
    log(f"Corpo da resposta: {resposta}")
    log(f"Resultado: {resultado}")
    log("=" * 70)

    return {
        "teste": nome,
        "hora": inicio.strftime("%H:%M:%S.%f")[:-3],
        "method": method,
        "url": url,
        "request_body": json.dumps(body, ensure_ascii=False) if body is not None else None,
        "esperado": esperado,
        "obtido": codigo,
        "duracao_ms": duracao_ms,
        "resultado": resultado,
        "resposta": resposta,
    }


def main():
    parser = argparse.ArgumentParser(description="Testa a API Biblioteca Pessoal de ponta a ponta.")
    parser.add_argument("--base-url", default="http://localhost", help="URL base da aplicação (padrão: http://localhost)")
    args = parser.parse_args()
    base = args.base_url.rstrip("/")

    results = []
    sufixo = datetime.now().strftime("%Y%m%d%H%M%S")  # evita colisão de ISBN entre execuções

    # 1. Infra
    results.append(run_test("Swagger (/api/docs)", "GET", f"{base}/api/docs", esperado=200))
    results.append(run_test("Health check (/api/health)", "GET", f"{base}/api/health", esperado=200))

    # 2. Ciclo CRUD completo
    novo_livro = {
        "title": "O Hobbit", "author": "J. R. R. Tolkien", "category": "Fantasia",
        "reading_status": "LENDO", "isbn": f"hob-{sufixo}",
    }
    r_criar = run_test("Criar livro (POST)", "POST", f"{base}/api/books", body=novo_livro, esperado=201)
    results.append(r_criar)
    livro_id = json.loads(r_criar["resposta"])["id"]

    results.append(run_test("Listar livros (GET /api/books)", "GET", f"{base}/api/books", esperado=200))
    results.append(run_test("Consultar livro criado (GET /api/books/{id})", "GET", f"{base}/api/books/{livro_id}", esperado=200))

    livro_substituido = {
        "title": "O Hobbit", "author": "J. R. R. Tolkien", "category": "Fantasia",
        "reading_status": "LIDO", "rating": 5, "isbn": f"hob-{sufixo}",
    }
    results.append(run_test("Substituir livro (PUT)", "PUT", f"{base}/api/books/{livro_id}", body=livro_substituido, esperado=200))

    results.append(run_test("Alterar status (PATCH /status)", "PATCH", f"{base}/api/books/{livro_id}/status",
                             body={"reading_status": "LENDO"}, esperado=200))

    results.append(run_test("Excluir livro (DELETE)", "DELETE", f"{base}/api/books/{livro_id}", esperado=204))
    results.append(run_test("Confirmar exclusão (GET id apagado)", "GET", f"{base}/api/books/{livro_id}", esperado=404))

    # 3. Validação de dados inválidos
    results.append(run_test("Rejeitar título vazio (POST)", "POST", f"{base}/api/books",
                             body={"title": "", "author": "X"}, esperado=422))
    results.append(run_test("Rejeitar rating fora de 1-5 (POST)", "POST", f"{base}/api/books",
                             body={"title": "A", "author": "B", "rating": 9}, esperado=422))

    # 4. ISBN duplicado
    livro_isbn = {"title": "Livro A", "author": "X", "isbn": f"dup-{sufixo}"}
    r_isbn = run_test("Criar livro com ISBN (POST)", "POST", f"{base}/api/books", body=livro_isbn, esperado=201)
    results.append(r_isbn)
    id_isbn = json.loads(r_isbn["resposta"])["id"]

    livro_isbn_dup = {"title": "Livro B", "author": "Y", "isbn": f"dup-{sufixo}"}
    results.append(run_test("Rejeitar ISBN duplicado (POST)", "POST", f"{base}/api/books", body=livro_isbn_dup, esperado=409))

    results.append(run_test("Limpar livro de teste de ISBN (DELETE)", "DELETE", f"{base}/api/books/{id_isbn}", esperado=204))

    # 5. Relatório em Markdown
    total_ok = sum(1 for r in results if r["resultado"] == "OK")
    total = len(results)

    linhas = []
    linhas.append("# Relatório de testes da API - Biblioteca Pessoal")
    linhas.append("")
    linhas.append(f"Gerado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    linhas.append("")
    linhas.append(f"**Resultado geral: {total_ok} / {total} testes OK**")
    linhas.append("")
    linhas.append("## Resumo")
    linhas.append("")
    linhas.append("| # | Teste | Hora | Esperado | Obtido | Duração | Resultado |")
    linhas.append("|---|---|---|---|---|---|---|")
    for i, r in enumerate(results, 1):
        linhas.append(f"| {i} | {r['teste']} | {r['hora']} | {r['esperado']} | {r['obtido']} | {r['duracao_ms']}ms | {r['resultado']} |")

    linhas.append("")
    linhas.append("## Log detalhado por teste")
    linhas.append("")
    linhas.append("Requisição e resposta reais de cada teste, na ordem em que rodaram.")
    linhas.append("")
    for i, r in enumerate(results, 1):
        linhas.append(f"### {i}. {r['teste']} — {r['resultado']}")
        linhas.append("")
        linhas.append(f"- Hora: `{r['hora']}`")
        linhas.append(f"- Requisição: `{r['method']} {r['url']}`")
        if r["request_body"]:
            linhas.append("- Corpo enviado:")
            linhas.append("")
            linhas.append("```json")
            linhas.append(r["request_body"])
            linhas.append("```")
        linhas.append(f"- Status esperado: `{r['esperado']}` / obtido: `{r['obtido']}` ({r['duracao_ms']}ms)")
        linhas.append("- Corpo da resposta:")
        linhas.append("")
        linhas.append("```json")
        linhas.append(r["resposta"])
        linhas.append("```")
        linhas.append("")

    linhas.append("## Log completo da execução")
    linhas.append("")
    linhas.append("Saída de console completa e sem edição, na ordem em que os testes rodaram.")
    linhas.append("")
    linhas.append("```text")
    linhas.extend(LOG_LINES)
    linhas.append("```")

    report_path = SCRIPT_DIR / "relatorio-testes-api.md"
    report_path.write_text("\n".join(linhas), encoding="utf-8")

    # 6. Resumo final no console
    print()
    print("=" * 70)
    print("RESUMO FINAL")
    print("=" * 70)
    for r in results:
        marca = "[OK]    " if r["resultado"] == "OK" else "[FALHOU]"
        print(f"{marca} {r['teste']}")
    print("=" * 70)
    print(f"Total: {total_ok}/{total} testes OK")
    if total_ok != total:
        print(f"{total - total_ok} teste(s) falharam - veja o relatório para detalhes.")
    print("=" * 70)
    print()
    print(f"Relatório gerado em: {report_path}")

    codigo_saida = 0 if total_ok == total else 1
    input("\nPressione Enter para fechar...")
    return codigo_saida


if __name__ == "__main__":
    sys.exit(main())

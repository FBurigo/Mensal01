#!/usr/bin/env python3
"""
Validação da integração dos 3 containers (Biblioteca Pessoal): redes
(isolamento edge/data), proxy /api do frontend, health checks dos 3 serviços
e o volume do MySQL (existência + persistência real, reiniciando os
containers). Funciona em Windows, Linux e macOS -- só precisa de Python
3.7+ e do Docker/Docker Compose instalados, nenhuma dependência externa
de Python.

Uso:
    python3 test_integracao.py
    python3 test_integracao.py --base-url http://localhost
    python3 test_integracao.py --ci --report-dir artifacts

Pré-requisito: rodar a partir da pasta do projeto (onde está o
compose.yaml), com os containers já no ar (docker compose up -d --build).
Este script reinicia os containers (docker compose restart) para testar
persistência -- não usa "down -v", os dados não são apagados.

Gera relatorio-integracao.md na pasta indicada por --report-dir (por padrão,
na mesma pasta do script), com resumo, log de cada checagem e o log completo
da execução.
"""

import argparse
import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
LOG_LINES = []


def log(msg=""):
    print(msg)
    LOG_LINES.append(str(msg))


def run(cmd, cwd=None):
    """Roda um comando externo e devolve (returncode, stdout+stderr)."""
    proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    saida = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode, saida.strip()


def http_request(method, url, body=None):
    data = None
    headers = {}
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
        headers["Content-Type"] = "application/json; charset=utf-8"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return (
                resp.status,
                resp.read().decode("utf-8", errors="replace"),
                dict(resp.headers.items()),
            )
    except urllib.error.HTTPError as exc:
        return (
            exc.code,
            exc.read().decode("utf-8", errors="replace"),
            dict((exc.headers or {}).items()),
        )
    except urllib.error.URLError as exc:
        return 0, f"(falha de conexão: {exc.reason})", {}


def detect_project(script_dir):
    compose_yaml = script_dir / "compose.yaml"
    if compose_yaml.exists():
        for linha in compose_yaml.read_text(encoding="utf-8").splitlines()[:5]:
            m = re.match(r"^name:\s*(.+)$", linha.strip())
            if m:
                return m.group(1).strip()
    return "biblioteca-pessoal"


def container_health(container):
    code, out = run(
        ["docker", "inspect", container, "--format", "{{.State.Health.Status}}"]
    )
    return out.strip() if code == 0 else f"(erro: {out})"


SPINNER = "|/-\\"


def wait_healthy(container, timeout_sec=90):
    """Espera o container ficar 'healthy', mostrando uma barra/spinner de
    progresso no console (pra ficar claro que o script não travou)."""
    inicio = time.time()
    i = 0
    largura_barra = 30
    while True:
        status = container_health(container)
        decorrido = time.time() - inicio
        if status == "healthy":
            linha = f"  [{container}] healthy (levou {round(decorrido)}s)"
            print("\r" + linha + " " * 20)
            LOG_LINES.append(linha.strip())
            return True
        if decorrido >= timeout_sec:
            linha = f"  [{container}] NAO ficou healthy em {timeout_sec}s (status atual: {status})"
            print("\r" + linha + " " * 20)
            LOG_LINES.append(linha.strip())
            return False

        proporcao = min(decorrido / timeout_sec, 1.0)
        preenchido = int(largura_barra * proporcao)
        barra = "#" * preenchido + "-" * (largura_barra - preenchido)
        spin = SPINNER[i % len(SPINNER)]
        print(
            f"\r  {spin} aguardando [{container}] ficar healthy [{barra}] "
            f"{round(decorrido)}s/{timeout_sec}s (status: {status})    ",
            end="",
            flush=True,
        )
        i += 1
        time.sleep(1)


def network_containers(network):
    code, out = run(
        [
            "docker",
            "network",
            "inspect",
            network,
            "--format",
            "{{range .Containers}}{{.Name}} {{end}}",
        ]
    )
    if code != 0:
        return []
    return [n for n in out.strip().split() if n]


resultados = []


def registrar(nome, passou, esperado, obtido, detalhe):
    resultado = "OK" if passou else "FALHOU"
    log("")
    log("=" * 70)
    log(f"CHECAGEM: {nome}")
    log(f"Esperado: {esperado}")
    log(f"Obtido:   {obtido}")
    log("--- log ---")
    log(detalhe)
    log(f"Resultado: {resultado}")
    log("=" * 70)
    resultados.append(
        {
            "nome": nome,
            "esperado": esperado,
            "obtido": obtido,
            "log": detalhe,
            "resultado": resultado,
        }
    )


def main():
    parser = argparse.ArgumentParser(
        description="Valida a integração dos containers Biblioteca Pessoal."
    )
    parser.add_argument(
        "--base-url",
        default="http://localhost",
        help="URL base da aplicação (padrão: http://localhost)",
    )
    parser.add_argument(
        "--ci",
        action="store_true",
        help="Executa sem pausa interativa ao finalizar",
    )
    parser.add_argument(
        "--report-dir",
        type=Path,
        default=SCRIPT_DIR,
        help="Diretório onde o relatório será salvo",
    )
    args = parser.parse_args()
    base = args.base_url.rstrip("/")
    report_dir = args.report_dir.resolve()
    report_dir.mkdir(parents=True, exist_ok=True)

    projeto = detect_project(SCRIPT_DIR)
    frontend = f"{projeto}-frontend-1"
    backend = f"{projeto}-backend-1"
    database = f"{projeto}-database-1"
    rede_edge = f"{projeto}_edge"
    rede_data = f"{projeto}_data"
    volume = f"{projeto}_mysql_data"

    log(f"Projeto Compose detectado: {projeto}")

    # ------------------------------------------------------------------
    # 1. Redes
    # ------------------------------------------------------------------
    edge_containers = network_containers(rede_edge)
    edge_ok = frontend in edge_containers and backend in edge_containers
    registrar(
        "Rede 'edge' conecta frontend e backend",
        edge_ok,
        f"contém {frontend} e {backend}",
        " ".join(edge_containers),
        f"docker network inspect {rede_edge} --format ...\n{' '.join(edge_containers)}",
    )

    data_containers = network_containers(rede_data)
    data_ok = (
        backend in data_containers
        and database in data_containers
        and frontend not in data_containers
    )
    registrar(
        "Rede 'data' conecta backend e database (sem frontend)",
        data_ok,
        f"contém {backend} e {database}, NÃO contém {frontend}",
        " ".join(data_containers),
        f"docker network inspect {rede_data} --format ...\n{' '.join(data_containers)}",
    )

    code, internal_out = run(
        ["docker", "network", "inspect", rede_data, "--format", "{{.Internal}}"]
    )
    internal_ok = internal_out.strip() == "true"
    registrar(
        "Rede 'data' é interna (isolada, sem saída)",
        internal_ok,
        "true",
        internal_out.strip(),
        f'docker network inspect {rede_data} --format "{{{{.Internal}}}}"\n{internal_out}',
    )

    # ------------------------------------------------------------------
    # 2. Proxy /api
    # ------------------------------------------------------------------
    codigo, corpo, headers = http_request("GET", f"{base}/api/health")
    server_header = headers.get("Server", "")
    proxy_ok = (
        codigo == 200
        and "nginx" in server_header.lower()
        and '"database":"connected"' in corpo
    )
    registrar(
        "Proxy /api do frontend para o backend",
        proxy_ok,
        "200, header Server: nginx, database:connected",
        "ver log",
        f"GET {base}/api/health\nStatus: {codigo}\nServer: {server_header}\nCorpo: {corpo}",
    )

    _, port_frontend = run(["docker", "port", frontend])
    _, port_backend = run(["docker", "port", backend])
    _, port_database = run(["docker", "port", database])
    ports_ok = (
        (not port_backend.strip())
        and (not port_database.strip())
        and ("80" in port_frontend)
    )
    registrar(
        "Somente a porta do frontend está publicada no host",
        ports_ok,
        "frontend com porta mapeada; backend e database sem porta publicada",
        f"frontend=[{port_frontend}] backend=[{port_backend}] database=[{port_database}]",
        f"docker port {frontend}\n{port_frontend}\n\ndocker port {backend}\n{port_backend}\n\ndocker port {database}\n{port_database}",
    )

    # ------------------------------------------------------------------
    # 3. Health checks
    # ------------------------------------------------------------------
    h_frontend = container_health(frontend)
    h_backend = container_health(backend)
    h_database = container_health(database)
    health_ok = (
        h_frontend == "healthy" and h_backend == "healthy" and h_database == "healthy"
    )
    registrar(
        "Os 3 serviços estão 'healthy'",
        health_ok,
        "healthy nos 3",
        f"frontend={h_frontend} backend={h_backend} database={h_database}",
        f"docker inspect {frontend} --format ... -> {h_frontend}\n"
        f"docker inspect {backend} --format ... -> {h_backend}\n"
        f"docker inspect {database} --format ... -> {h_database}",
    )

    # ------------------------------------------------------------------
    # 4. Volume: existência
    # ------------------------------------------------------------------
    code, vol_info = run(
        [
            "docker",
            "volume",
            "inspect",
            volume,
            "--format",
            "{{.Name}}: {{.Mountpoint}}",
        ]
    )
    vol_ok = code == 0
    registrar(
        "Volume do MySQL existe",
        vol_ok,
        f"volume {volume} existe",
        vol_info,
        f"docker volume inspect {volume} --format ...\n{vol_info}",
    )

    # ------------------------------------------------------------------
    # 5. Volume: persistência real (cadastra, reinicia, confere)
    # ------------------------------------------------------------------
    marcador = f"Evidencia de persistencia {datetime.now().strftime('%Y%m%d%H%M%S')}"
    log_persist = []
    id_marcador = None
    persist_ok = False

    try:
        body_criar = {
            "title": marcador,
            "author": "Script de integracao",
            "category": "Teste",
            "reading_status": "LENDO",
        }
        codigo, corpo, _ = http_request("POST", f"{base}/api/books", body=body_criar)
        id_marcador = json.loads(corpo)["id"]
        log_persist.append(f"POST {base}/api/books -> {codigo}, id={id_marcador}")

        log_persist.append("\ndocker compose restart")
        print("\nReiniciando os containers (docker compose restart)...")
        _, restart_out = run(["docker", "compose", "restart"], cwd=SCRIPT_DIR)
        print("Reinício disparado. Aguardando os 3 containers ficarem healthy de novo:")
        log_persist.append(restart_out)

        ok_frontend = wait_healthy(frontend)
        ok_backend = wait_healthy(backend)
        ok_database = wait_healthy(database)
        log_persist.append(
            f"\nApós restart -> frontend healthy={ok_frontend}, backend healthy={ok_backend}, database healthy={ok_database}"
        )

        codigo, corpo, _ = http_request("GET", f"{base}/api/books/{id_marcador}")
        titulo_confirmado = json.loads(corpo).get("title") if codigo == 200 else None
        log_persist.append(
            f"\nGET {base}/api/books/{id_marcador} -> {codigo}\nCorpo: {corpo}"
        )

        persist_ok = (
            ok_frontend
            and ok_backend
            and ok_database
            and (titulo_confirmado == marcador)
        )
    except Exception as exc:
        log_persist.append(f"\nFalhou: {exc}")
        persist_ok = False

    registrar(
        "Persistência do volume (cadastro sobrevive a docker compose restart)",
        persist_ok,
        f"livro '{marcador}' continua existindo e os 3 containers voltam healthy",
        "ver log",
        "\n".join(log_persist),
    )

    if id_marcador:
        try:
            http_request("DELETE", f"{base}/api/books/{id_marcador}")
        except Exception:
            pass

    # ------------------------------------------------------------------
    # Relatório em Markdown
    # ------------------------------------------------------------------
    total_ok = sum(1 for r in resultados if r["resultado"] == "OK")
    total = len(resultados)

    linhas = []
    linhas.append("# Relatório de integração dos containers - Biblioteca Pessoal")
    linhas.append("")
    linhas.append(f"Gerado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    linhas.append(f"Projeto Compose: `{projeto}`")
    linhas.append("")
    linhas.append(f"**Resultado geral: {total_ok} / {total} checagens OK**")
    linhas.append("")
    linhas.append("## Resumo")
    linhas.append("")
    linhas.append("| # | Checagem | Esperado | Obtido | Resultado |")
    linhas.append("|---|---|---|---|---|")
    for i, r in enumerate(resultados, 1):
        linhas.append(
            f"| {i} | {r['nome']} | {r['esperado']} | {r['obtido']} | {r['resultado']} |"
        )

    linhas.append("")
    linhas.append("## Log detalhado por checagem")
    linhas.append("")
    for i, r in enumerate(resultados, 1):
        linhas.append(f"### {i}. {r['nome']} — {r['resultado']}")
        linhas.append("")
        linhas.append(f"- Esperado: {r['esperado']}")
        linhas.append(f"- Obtido: {r['obtido']}")
        linhas.append("- Log:")
        linhas.append("")
        linhas.append("```text")
        linhas.append(r["log"])
        linhas.append("```")
        linhas.append("")

    linhas.append("## Log completo da execução")
    linhas.append("")
    linhas.append(
        "Saída de console completa e sem edição, na ordem em que as checagens rodaram."
    )
    linhas.append("")
    linhas.append("```text")
    linhas.extend(LOG_LINES)
    linhas.append("```")

    report_path = report_dir / "relatorio-integracao.md"
    report_path.write_text("\n".join(linhas), encoding="utf-8")

    # Resumo final no console
    print()
    print("=" * 70)
    print("RESUMO FINAL")
    print("=" * 70)
    for r in resultados:
        marca = "[OK]    " if r["resultado"] == "OK" else "[FALHOU]"
        print(f"{marca} {r['nome']}")
    print("=" * 70)
    print(f"Total: {total_ok}/{total} checagens OK")
    if total_ok != total:
        print(
            f"{total - total_ok} checagem(ns) falharam - veja o relatório para detalhes."
        )
    print("=" * 70)
    print()
    print(f"Relatório gerado em: {report_path}")

    codigo_saida = 0 if total_ok == total else 1
    if not args.ci:
        input("\nPressione Enter para fechar...")
    return codigo_saida


if __name__ == "__main__":
    sys.exit(main())

@echo off
title Biblioteca Pessoal - Dev Server
cd /d "%~dp0backend"

echo.
echo  Instalando dependencias Python...
python -m pip install -r requirements.txt --quiet
if %ERRORLEVEL% neq 0 (
    echo ERRO: Python nao encontrado. Instale o Python 3.11+ e tente novamente.
    pause
    exit /b 1
)

echo  Instalando aiofiles (necessario para servir o frontend)...
python -m pip install aiofiles --quiet

echo  Aplicando migrations no SQLite...
set DATABASE_URL=sqlite+pysqlite:///./biblioteca_dev.db
python -m alembic upgrade head
if %ERRORLEVEL% neq 0 (
    echo ERRO: falha nas migrations.
    pause
    exit /b 1
)

echo.
echo  ============================================
echo   Servidor iniciado em http://localhost:8000
echo   Docs da API:  http://localhost:8000/api/docs
echo   Ctrl+C para parar
echo  ============================================
echo.

python -m uvicorn dev_server:app --reload --host 127.0.0.1 --port 8000

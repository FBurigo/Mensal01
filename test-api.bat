@echo off
REM Roda a bateria de testes da API Biblioteca Pessoal e gera
REM relatorio-testes-api.md na mesma pasta.
REM Pre-requisito: containers no ar (docker compose up -d).

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0test-api.ps1"

echo.
pause

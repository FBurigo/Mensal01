<#
    Script de validação da API Biblioteca Pessoal.
    Roda uma bateria de testes contra a API (Swagger, health, CRUD completo,
    validação de dados inválidos e ISBN duplicado) e gera um relatório em
    Markdown com o resultado de cada teste, o log de requisição/resposta de
    cada teste individualmente, e o log bruto completo da execução.

    Uso:
        .\test-api.bat
    (ou diretamente: powershell -ExecutionPolicy Bypass -File .\test-api.ps1)

    Pré-requisito: containers no ar (docker compose up -d) e app acessível
    em http://localhost (ajuste $Base abaixo se usar outra porta).
#>

$ErrorActionPreference = 'Stop'
$Base       = "http://localhost"
$Report     = Join-Path $PSScriptRoot "relatorio-testes-api.md"
$TransLog   = Join-Path $PSScriptRoot "_transcript-temp.log"

# Garante que a saída no console também sai em UTF-8 (evita acentos quebrados)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Start-Transcript -Path $TransLog -Force | Out-Null

function Invoke-Test {
    param(
        [string]$Nome,
        [string]$Method,
        [string]$Url,
        [string]$Body = $null,
        [int]$Esperado
    )

    $inicio = Get-Date

    try {
        if ($Body) {
            $resp = Invoke-WebRequest -Uri $Url -Method $Method -Body $Body `
                -ContentType "application/json" -UseBasicParsing
        } else {
            $resp = Invoke-WebRequest -Uri $Url -Method $Method -UseBasicParsing
        }
        $code = [int]$resp.StatusCode
        $content = $resp.Content
    } catch {
        # No Windows PowerShell 5.1, Invoke-WebRequest lança exceção em 4xx/5xx.
        # O corpo da resposta de erro vem em $_.ErrorDetails.Message (ler o
        # stream manualmente às vezes retorna vazio porque já foi consumido).
        $webResp = $_.Exception.Response
        if ($webResp) {
            $code = [int]$webResp.StatusCode
        } else {
            $code = 0
        }
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $content = $_.ErrorDetails.Message
        } elseif ($webResp) {
            try {
                $stream = $webResp.GetResponseStream()
                $stream.Position = 0
                $reader = New-Object System.IO.StreamReader($stream)
                $content = $reader.ReadToEnd()
            } catch {
                $content = "(não foi possível ler o corpo da resposta de erro: $($_.Exception.Message))"
            }
        } else {
            $content = $_.Exception.Message
        }
    }

    $fim = Get-Date
    $duracaoMs = [math]::Round(($fim - $inicio).TotalMilliseconds)
    $resultado = if ($code -eq $Esperado) { "OK" } else { "FALHOU" }

    Write-Host ""
    Write-Host "==================================================================="
    Write-Host "TESTE: $Nome"
    Write-Host "Hora: $($inicio.ToString('yyyy-MM-dd HH:mm:ss.fff'))"
    Write-Host "Requisicao: $Method $Url"
    if ($Body) { Write-Host "Corpo enviado: $Body" }
    Write-Host "Status esperado: $Esperado | Status obtido: $code | Duracao: ${duracaoMs}ms"
    Write-Host "Corpo da resposta: $content"
    Write-Host "Resultado: $resultado"
    Write-Host "==================================================================="

    [PSCustomObject]@{
        Teste        = $Nome
        Hora         = $inicio.ToString('HH:mm:ss.fff')
        Method       = $Method
        Url          = $Url
        RequestBody  = $Body
        Esperado     = $Esperado
        Obtido       = $code
        DuracaoMs    = $duracaoMs
        Resultado    = $resultado
        Resposta     = $content
    }
}

$results = @()
$sufixo  = Get-Date -Format "yyyyMMddHHmmss"   # evita colisão de ISBN entre execuções

# 1. Infra
$results += Invoke-Test -Nome "Swagger (/api/docs)" -Method GET -Url "$Base/api/docs" -Esperado 200
$results += Invoke-Test -Nome "Health check (/api/health)" -Method GET -Url "$Base/api/health" -Esperado 200

# 2. Ciclo CRUD completo
$novoLivro = @{ title = "O Hobbit"; author = "J. R. R. Tolkien"; category = "Fantasia"; reading_status = "LENDO"; isbn = "hob-$sufixo" } | ConvertTo-Json
$rCriar = Invoke-Test -Nome "Criar livro (POST)" -Method POST -Url "$Base/api/books" -Body $novoLivro -Esperado 201
$results += $rCriar
$id = ($rCriar.Resposta | ConvertFrom-Json).id

$results += Invoke-Test -Nome "Listar livros (GET /api/books)" -Method GET -Url "$Base/api/books" -Esperado 200
$results += Invoke-Test -Nome "Consultar livro criado (GET /api/books/{id})" -Method GET -Url "$Base/api/books/$id" -Esperado 200

$livroSubstituido = @{ title = "O Hobbit"; author = "J. R. R. Tolkien"; category = "Fantasia"; reading_status = "LIDO"; rating = 5; isbn = "hob-$sufixo" } | ConvertTo-Json
$results += Invoke-Test -Nome "Substituir livro (PUT)" -Method PUT -Url "$Base/api/books/$id" -Body $livroSubstituido -Esperado 200

$statusBody = @{ reading_status = "LENDO" } | ConvertTo-Json
$results += Invoke-Test -Nome "Alterar status (PATCH /status)" -Method PATCH -Url "$Base/api/books/$id/status" -Body $statusBody -Esperado 200

$results += Invoke-Test -Nome "Excluir livro (DELETE)" -Method DELETE -Url "$Base/api/books/$id" -Esperado 204
$results += Invoke-Test -Nome "Confirmar exclusão (GET id apagado)" -Method GET -Url "$Base/api/books/$id" -Esperado 404

# 3. Validação de dados inválidos
$tituloVazio = @{ title = ""; author = "X" } | ConvertTo-Json
$results += Invoke-Test -Nome "Rejeitar título vazio (POST)" -Method POST -Url "$Base/api/books" -Body $tituloVazio -Esperado 422

$ratingInvalido = @{ title = "A"; author = "B"; rating = 9 } | ConvertTo-Json
$results += Invoke-Test -Nome "Rejeitar rating fora de 1-5 (POST)" -Method POST -Url "$Base/api/books" -Body $ratingInvalido -Esperado 422

# 4. ISBN duplicado
$livroIsbn = @{ title = "Livro A"; author = "X"; isbn = "dup-$sufixo" } | ConvertTo-Json
$rIsbn = Invoke-Test -Nome "Criar livro com ISBN (POST)" -Method POST -Url "$Base/api/books" -Body $livroIsbn -Esperado 201
$results += $rIsbn
$idIsbn = ($rIsbn.Resposta | ConvertFrom-Json).id

$livroIsbnDup = @{ title = "Livro B"; author = "Y"; isbn = "dup-$sufixo" } | ConvertTo-Json
$results += Invoke-Test -Nome "Rejeitar ISBN duplicado (POST)" -Method POST -Url "$Base/api/books" -Body $livroIsbnDup -Esperado 409

$results += Invoke-Test -Nome "Limpar livro de teste de ISBN (DELETE)" -Method DELETE -Url "$Base/api/books/$idIsbn" -Esperado 204

Stop-Transcript | Out-Null
$transcriptTexto = Get-Content -Path $TransLog -Raw
Remove-Item $TransLog -Force -ErrorAction SilentlyContinue

# 5. Gerar relatório em Markdown
$totalOk = ($results | Where-Object { $_.Resultado -eq "OK" }).Count
$total   = $results.Count

$linhas = @()
$linhas += "# Relatório de testes da API - Biblioteca Pessoal"
$linhas += ""
$linhas += "Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$linhas += ""
$linhas += "**Resultado geral: $totalOk / $total testes OK**"
$linhas += ""
$linhas += "## Resumo"
$linhas += ""
$linhas += "| # | Teste | Hora | Esperado | Obtido | Duração | Resultado |"
$linhas += "|---|---|---|---|---|---|---|"
$i = 0
foreach ($r in $results) {
    $i++
    $linhas += "| $i | $($r.Teste) | $($r.Hora) | $($r.Esperado) | $($r.Obtido) | $($r.DuracaoMs)ms | $($r.Resultado) |"
}

$linhas += ""
$linhas += "## Log detalhado por teste"
$linhas += ""
$linhas += "Requisição e resposta reais de cada teste, na ordem em que rodaram."
$linhas += ""
$i = 0
foreach ($r in $results) {
    $i++
    $linhas += "### $i. $($r.Teste) — $($r.Resultado)"
    $linhas += ""
    $linhas += "- Hora: ``$($r.Hora)``"
    $linhas += "- Requisição: ``$($r.Method) $($r.Url)``"
    if ($r.RequestBody) {
        $linhas += "- Corpo enviado:"
        $linhas += ""
        $linhas += '```json'
        $linhas += $r.RequestBody
        $linhas += '```'
    }
    $linhas += "- Status esperado: ``$($r.Esperado)`` / obtido: ``$($r.Obtido)`` ($($r.DuracaoMs)ms)"
    $linhas += "- Corpo da resposta:"
    $linhas += ""
    $linhas += '```json'
    $linhas += $r.Resposta
    $linhas += '```'
    $linhas += ""
}

$linhas += "## Log completo da execução (transcript bruto)"
$linhas += ""
$linhas += "Saída de console completa e sem edição, gerada pelo `Start-Transcript` do"
$linhas += "PowerShell durante a execução deste script — serve como prova de que os"
$linhas += "testes acima realmente rodaram, na ordem mostrada."
$linhas += ""
$linhas += '```text'
$linhas += $transcriptTexto
$linhas += '```'

# Escreve em UTF-8 com BOM explicitamente (evita acentos quebrados em qualquer terminal/editor)
$conteudoFinal = ($linhas -join "`r`n")
[System.IO.File]::WriteAllText($Report, $conteudoFinal, (New-Object System.Text.UTF8Encoding($true)))

Write-Host ""
Write-Host "Relatório gerado em: $Report"

if ($totalOk -ne $total) {
    exit 1
}

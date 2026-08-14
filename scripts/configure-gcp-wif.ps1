[CmdletBinding()]
param(
    [string]$ProjectId = "mensal-01-2602",
    [string]$Repository = "FBurigo/Mensal01",
    [string]$PoolId = "github-actions",
    [string]$ProviderId = "mensal01-main",
    [string]$ServiceAccountId = "github-deploy",
    [string]$CustomRoleId = "githubDeploySsh"
)

$ErrorActionPreference = "Stop"

$gcloud = Get-Command gcloud -ErrorAction SilentlyContinue
if (-not $gcloud) {
    $localSdk = Join-Path $env:LOCALAPPDATA "Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
    if (-not (Test-Path -LiteralPath $localSdk)) {
        throw "Google Cloud CLI não encontrado."
    }
    $gcloudPath = $localSdk
}
else {
    $gcloudPath = $gcloud.Source
}

function Invoke-Gcloud {
    & $gcloudPath @args
    if ($LASTEXITCODE -ne 0) {
        throw "gcloud falhou: $($args -join ' ')"
    }
}

function Test-GcloudResource {
    param([string[]]$Arguments)

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    & $gcloudPath @Arguments *> $null
    $succeeded = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $previousPreference
    return $succeeded
}

$serviceAccount = "$ServiceAccountId@$ProjectId.iam.gserviceaccount.com"
$customRole = "projects/$ProjectId/roles/$CustomRoleId"
$repositoryCondition = "assertion.repository=='$Repository' && assertion.ref=='refs/heads/main'"
$attributeMapping = "google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref"
$permissions = @(
    "compute.globalOperations.get"
    "compute.instances.get"
    "compute.instances.setMetadata"
    "compute.projects.get"
    "compute.projects.setCommonInstanceMetadata"
    "compute.zoneOperations.get"
    "serviceusage.services.use"
) -join ","

Invoke-Gcloud services enable `
    compute.googleapis.com `
    iam.googleapis.com `
    iamcredentials.googleapis.com `
    sts.googleapis.com `
    --project=$ProjectId `
    --quiet

if (-not (Test-GcloudResource @(
            "iam", "service-accounts", "describe", $serviceAccount,
            "--project=$ProjectId"
        ))) {
    Invoke-Gcloud iam service-accounts create $ServiceAccountId `
        --project=$ProjectId `
        --display-name="GitHub Actions - deploy Mensal01"
}

if (Test-GcloudResource @(
        "iam", "roles", "describe", $CustomRoleId,
        "--project=$ProjectId"
    )) {
    Invoke-Gcloud iam roles update $CustomRoleId `
        --project=$ProjectId `
        --title="Deploy SSH efêmero do GitHub Actions" `
        --permissions=$permissions `
        --stage=GA
}
else {
    Invoke-Gcloud iam roles create $CustomRoleId `
        --project=$ProjectId `
        --title="Deploy SSH efêmero do GitHub Actions" `
        --permissions=$permissions `
        --stage=GA
}

Invoke-Gcloud projects add-iam-policy-binding $ProjectId `
    --member="serviceAccount:$serviceAccount" `
    --role=$customRole `
    --condition=None `
    --quiet

if (-not (Test-GcloudResource @(
            "iam", "workload-identity-pools", "describe", $PoolId,
            "--project=$ProjectId", "--location=global"
        ))) {
    Invoke-Gcloud iam workload-identity-pools create $PoolId `
        --project=$ProjectId `
        --location=global `
        --display-name="GitHub Actions"
}

if (Test-GcloudResource @(
        "iam", "workload-identity-pools", "providers", "describe", $ProviderId,
        "--project=$ProjectId", "--location=global",
        "--workload-identity-pool=$PoolId"
    )) {
    Invoke-Gcloud iam workload-identity-pools providers update-oidc $ProviderId `
        --project=$ProjectId `
        --location=global `
        --workload-identity-pool=$PoolId `
        --issuer-uri="https://token.actions.githubusercontent.com/" `
        --attribute-mapping=$attributeMapping `
        --attribute-condition=$repositoryCondition
}
else {
    Invoke-Gcloud iam workload-identity-pools providers create-oidc $ProviderId `
        --project=$ProjectId `
        --location=global `
        --workload-identity-pool=$PoolId `
        --display-name="Mensal01 main" `
        --issuer-uri="https://token.actions.githubusercontent.com/" `
        --attribute-mapping=$attributeMapping `
        --attribute-condition=$repositoryCondition
}

$projectNumber = (& $gcloudPath projects describe $ProjectId --format="value(projectNumber)").Trim()
if ($LASTEXITCODE -ne 0 -or -not $projectNumber) {
    throw "Não foi possível consultar o número do projeto."
}

$principal = "principalSet://iam.googleapis.com/projects/$projectNumber/locations/global/workloadIdentityPools/$PoolId/attribute.repository/$Repository"
Invoke-Gcloud iam service-accounts add-iam-policy-binding $serviceAccount `
    --project=$ProjectId `
    --member=$principal `
    --role="roles/iam.workloadIdentityUser" `
    --quiet

$providerName = (& $gcloudPath iam workload-identity-pools providers describe $ProviderId `
    --project=$ProjectId `
    --location=global `
    --workload-identity-pool=$PoolId `
    --format="value(name)").Trim()
if ($LASTEXITCODE -ne 0 -or -not $providerName) {
    throw "Não foi possível consultar o nome completo do provider."
}

Write-Output "GCP_PROJECT_ID=$ProjectId"
Write-Output "GCP_WIF_PROVIDER=$providerName"
Write-Output "GCP_SERVICE_ACCOUNT=$serviceAccount"

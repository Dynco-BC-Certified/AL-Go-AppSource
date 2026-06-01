<#
.SYNOPSIS
    Aggiunge il submodule condiviso ".github" a una repo esistente.

.DESCRIPTION
    Esegui questo script dalla root della repo TARGET (non dalla repo del submodule).
    Aggiunge https://github.com/Dynco-Internal/Dynamics-VsCode-Copilot come submodule
    nella cartella .github e lo inizializza.

.EXAMPLE
    cd C:\Progetti\MiaRepo
    & ".\.github\Add-Submodule.ps1"         # se .github esiste già
    # oppure scarica lo script e lancialo da fuori:
    powershell -File "path\to\Add-Submodule.ps1"

.NOTES
    La repo deve essere già inizializzata come git repo (git init o clonata).
#>

# test

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SubmoduleUrl = 'https://github.com/Dynco-Internal/Dynamics-VsCode-Copilot'
$SubmodulePath = 'App/.github'

# Verifica che siamo in una git repo
if (-not (Test-Path '.git') -and -not (git rev-parse --git-dir 2>$null)) {
    Write-Error "La directory corrente non è una git repository. Esegui 'git init' prima."
    exit 1
}

# Verifica che .github non esista già come submodule
$existingModules = git submodule status 2>$null
if ($existingModules -match [regex]::Escape($SubmodulePath)) {
    Write-Warning "Il submodule '$SubmodulePath' è già registrato in questa repo."
    exit 0
}

# Se esiste già una cartella .github non submodule
if (Test-Path $SubmodulePath) {
    Write-Error "La cartella '$SubmodulePath' esiste già e non è un submodule. Rimuovila prima di procedere."
    exit 1
}

Write-Host "Aggiunta submodule '$SubmodulePath' da $SubmoduleUrl ..." -ForegroundColor Cyan
git submodule add --force $SubmoduleUrl $SubmodulePath 

if ($LASTEXITCODE -ne 0) {
    Write-Error "Errore durante 'git submodule add'. Controlla l'output sopra."
    exit 1
}

Write-Host "Inizializzazione submodule ..." -ForegroundColor Cyan
git submodule update --init --recursive

if ($LASTEXITCODE -ne 0) {
    Write-Error "Errore durante 'git submodule update'."
    exit 1
}

Write-Host ""
Write-Host "Submodule '.github' aggiunto e inizializzato con successo." -ForegroundColor Green
Write-Host "Ricordati di fare commit di '.gitmodules' e '.github':" -ForegroundColor Yellow
Write-Host "  git add .gitmodules .github" -ForegroundColor Yellow
Write-Host "  git commit -m 'chore: add shared .github submodule'" -ForegroundColor Yellow

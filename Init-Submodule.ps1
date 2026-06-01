<#
.SYNOPSIS
    Inizializza e aggiorna tutti i submodule dopo aver clonato la repo.

.DESCRIPTION
    Esegui questo script dalla root della repo dopo un clone fresco.
    Esegue 'git submodule update --init --recursive' e, opzionalmente,
    configura il tracking del branch remoto.

.PARAMETER UpdateToLatest
    Se specificato, aggiorna il submodule all'ultimo commit del branch remoto
    invece di usare il commit pinnato dalla repo.

.EXAMPLE
    # Clone + init standard (usa il commit pinnato)
    git clone https://github.com/org/mia-repo
    cd mia-repo
    .\Init-Submodule.ps1

.EXAMPLE
    # Clone + aggiorna submodule all'ultimo commit remoto
    .\Init-Submodule.ps1 -UpdateToLatest

.NOTES
    Richiede Git installato e accessibile nel PATH.
#>

[CmdletBinding()]
param(
    [switch]$UpdateToLatest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Verifica che siamo in una git repo
if (-not (Test-Path '.git') -and -not (git rev-parse --git-dir 2>$null)) {
    Write-Error "La directory corrente non è una git repository."
    exit 1
}

# Verifica che esista almeno un submodule configurato
if (-not (Test-Path '.gitmodules')) {
    Write-Warning "Nessun file '.gitmodules' trovato. Nessun submodule da inizializzare."
    exit 0
}

Write-Host "Inizializzazione submodule ..." -ForegroundColor Cyan
git submodule update --init --recursive

if ($LASTEXITCODE -ne 0) {
    Write-Error "Errore durante 'git submodule update --init'."
    exit 1
}

if ($UpdateToLatest) {
    Write-Host "Aggiornamento submodule all'ultimo commit remoto ..." -ForegroundColor Cyan
    git submodule update --remote --merge

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Errore durante 'git submodule update --remote'."
        exit 1
    }

    Write-Host ""
    Write-Host "Submodule aggiornati all'ultimo commit remoto." -ForegroundColor Green
    Write-Host "Se vuoi pinnare questa versione nella repo, esegui:" -ForegroundColor Yellow
    Write-Host "  git add .github" -ForegroundColor Yellow
    Write-Host "  git commit -m 'chore: update .github submodule to latest'" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Submodule inizializzati al commit pinnato dalla repo." -ForegroundColor Green
    Write-Host "Per aggiornare all'ultima versione remota usa: .\Init-Submodule.ps1 -UpdateToLatest" -ForegroundColor DarkGray
}

# Mostra stato finale
Write-Host ""
Write-Host "Stato submodule:" -ForegroundColor Cyan
git submodule status

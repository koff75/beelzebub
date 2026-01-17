# Configure LOKI_URL pour le service Beelzebub sur Railway
# Les logs Beelzebub seront envoyes a Loki pour les dashboards Grafana (IP Analysis, etc.)
#
# Pre-requis: Railway CLI installe, projet lie (railway link) dans ce dossier
#
# Usage:
#   .\configure-loki-railway.ps1
#   .\configure-loki-railway.ps1 -LokiUrl "http://loki-xxxx.railway.internal:3100"

param(
    [string] $LokiUrl = "http://loki.railway.internal:3100"
)

$ErrorActionPreference = "Stop"

Write-Host "Configuration de LOKI_URL pour Beelzebub sur Railway" -ForegroundColor Cyan
Write-Host "  LOKI_URL = $LokiUrl" -ForegroundColor Gray
Write-Host ""

# Verifier que railway est installe
$railway = Get-Command railway -ErrorAction SilentlyContinue
if (-not $railway) {
    Write-Host "Erreur: Railway CLI non trouve. Installez-le: https://docs.railway.app/develop/cli" -ForegroundColor Red
    exit 1
}

# Definir LOKI_URL via -s beelzebub (pas besoin de railway service / link service)
railway variable set -s beelzebub "LOKI_URL=$LokiUrl"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Assurez-vous d'avoir lie le projet (railway link) depuis ce dossier." -ForegroundColor Yellow
    Write-Host "Erreur lors de la definition de LOKI_URL." -ForegroundColor Red
    exit 1
}

Write-Host "LOKI_URL a ete defini. Redeplez Beelzebub pour appliquer (ou attendez le prochain deploy)." -ForegroundColor Green
Write-Host ""
Write-Host "Pour declencher un redepoiement:" -ForegroundColor Gray
Write-Host "  railway up" -ForegroundColor Gray
Write-Host "  # ou poussez un commit sur le depot lie" -ForegroundColor Gray
Write-Host ""
Write-Host "Si votre service Loki a un autre hostname, relancez avec:" -ForegroundColor Gray
Write-Host "  .\configure-loki-railway.ps1 -LokiUrl 'http://VOTRE_LOKI.railway.internal:3100'" -ForegroundColor Gray

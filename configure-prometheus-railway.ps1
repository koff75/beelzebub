# Script PowerShell pour configurer Prometheus sur Railway via CLI
# Ce script configure Prometheus pour scraper les métriques de beelzebub

Write-Host "🔧 Configuration de Prometheus pour scraper beelzebub" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Railway CLI est installé
if (-not (Get-Command railway -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Railway CLI n'est pas installé" -ForegroundColor Red
    exit 1
}

# Vérifier que le projet est lié
$status = railway status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Aucun projet Railway n'est lié. Exécutez: railway link" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Projet Railway lié" -ForegroundColor Green
Write-Host ""

# Lier le service Prometheus
Write-Host "📊 Liaison du service Prometheus..." -ForegroundColor Yellow
Write-Host "Sélectionnez 'Prometheus' dans le menu qui s'affiche" -ForegroundColor Gray

# Note: railway service ouvre un menu interactif, donc on ne peut pas l'automatiser complètement
# L'utilisateur doit sélectionner Prometheus manuellement

Write-Host ""
Write-Host "Une fois Prometheus sélectionné, les variables suivantes seront configurées :" -ForegroundColor Cyan
Write-Host ""
Write-Host "Variables à configurer :" -ForegroundColor Yellow
Write-Host "  PROMETHEUS_TARGETS=beelzebub:https://3il-ingenieurs.site/metrics" -ForegroundColor White
Write-Host "  SCRAPE_INTERVAL=15s" -ForegroundColor White
Write-Host ""

# Lire le fichier de configuration
$configPath = "railway-prometheus-config.yml"
if (Test-Path $configPath) {
    Write-Host "📄 Fichier de configuration trouvé : $configPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Options de configuration :" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Option 1 : Via variables d'environnement (si Prometheus les supporte)" -ForegroundColor Yellow
    Write-Host "  railway variables --set 'PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 2 : Monter le fichier de configuration" -ForegroundColor Yellow
    Write-Host "  1. Allez dans Railway Dashboard > Prometheus > Settings > Volumes" -ForegroundColor Gray
    Write-Host "  2. Créez un volume et montez $configPath" -ForegroundColor Gray
    Write-Host "  3. Configurez PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 3 : Configuration manuelle dans l'interface Railway" -ForegroundColor Yellow
    Write-Host "  1. Allez dans Railway Dashboard > Prometheus" -ForegroundColor Gray
    Write-Host "  2. Ajoutez un target de scraping :" -ForegroundColor Gray
    Write-Host "     - Job name: beelzebub" -ForegroundColor Gray
    Write-Host "     - Target URL: https://3il-ingenieurs.site/metrics" -ForegroundColor Gray
    Write-Host "     - Scheme: https" -ForegroundColor Gray
    Write-Host "     - Scrape interval: 15s" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "⚠️  Fichier de configuration non trouvé : $configPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Pour configurer maintenant :" -ForegroundColor Cyan
Write-Host "  1. Exécutez : railway service" -ForegroundColor White
Write-Host "  2. Sélectionnez 'Prometheus'" -ForegroundColor White
Write-Host "  3. Exécutez : railway variables" -ForegroundColor White
Write-Host "  4. Ajoutez les variables nécessaires" -ForegroundColor White
Write-Host ""
Write-Host "📚 Consultez CONFIGURATION_ARCHITECTURE_EXISTANTE.md pour les details" -ForegroundColor Yellow

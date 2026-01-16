# Script de configuration Grafana/Prometheus/Loki pour Railway (PowerShell)

Write-Host "🚀 Configuration des services d'observabilité pour Beelzebub sur Railway" -ForegroundColor Green

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

# Afficher les instructions
Write-Host "📊 Configuration Prometheus:" -ForegroundColor Cyan
Write-Host "1. Allez dans le service Prometheus sur Railway Dashboard"
Write-Host "2. Dans l'onglet Variables, ajoutez ou modifiez:"
Write-Host "   - Montez le fichier railway-prometheus-config.yml"
Write-Host "   - OU configurez les targets dans l'interface Railway"
Write-Host "3. Target à ajouter: https://3il-ingenieurs.site/metrics"
Write-Host ""

Write-Host "📝 Configuration Loki:" -ForegroundColor Cyan
Write-Host "1. Allez dans le service Loki sur Railway Dashboard"
Write-Host "2. Montez les fichiers de configuration:"
Write-Host "   - loki-config/loki-config.yaml"
Write-Host "   - loki-config/promtail-config.yaml"
Write-Host "3. Déployez Promtail comme service séparé si nécessaire"
Write-Host ""

Write-Host "📈 Configuration Grafana:" -ForegroundColor Cyan
Write-Host "1. Accédez à Grafana (via le domaine Railway)"
Write-Host "2. Ajoutez les datasources:"
Write-Host "   - Prometheus: http://prometheus:9090 (UID: prometheus)"
Write-Host "   - Loki: http://loki:3100 (UID: loki)"
Write-Host "3. Importez les dashboards depuis grafana-dashboards/"
Write-Host ""

Write-Host "✅ Instructions affichées!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Consultez RAILWAY_GRAFANA_DEPLOY.md pour les instructions détaillées" -ForegroundColor Yellow

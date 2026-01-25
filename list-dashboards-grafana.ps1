# Script pour lister tous les dashboards Grafana via l'API REST
# Alternative si les outils MCP Grafana ne sont pas disponibles

param(
    [string]$GrafanaUrl = "",
    [string]$ApiKey = ""
)

if ([string]::IsNullOrEmpty($GrafanaUrl) -or [string]::IsNullOrEmpty($ApiKey)) {
    Write-Host "Usage: .\list-dashboards-grafana.ps1 -GrafanaUrl 'https://your-grafana-url' -ApiKey 'your-api-key'" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Liste des Dashboards Grafana ===" -ForegroundColor Cyan
Write-Host ""

# Si l'API key n'est pas fournie, demander
if ([string]::IsNullOrEmpty($ApiKey)) {
    Write-Host "⚠️  API Key non fournie. Vous pouvez :" -ForegroundColor Yellow
    Write-Host "   1. Créer un Service Account dans Grafana (Administration → Service accounts)"
    Write-Host "   2. Générer un token avec les permissions 'dashboards:read'"
    Write-Host "   3. Exécuter ce script avec : .\list-dashboards-grafana.ps1 -ApiKey 'votre_token'"
    Write-Host ""
    Write-Host "Ou utiliser les outils MCP Grafana si disponibles." -ForegroundColor Green
    exit 1
}

# Headers pour l'API Grafana
$headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

try {
    # Rechercher tous les dashboards
    Write-Host "Recherche des dashboards..." -ForegroundColor Yellow
    $searchUrl = "$GrafanaUrl/api/search?type=dash-db"
    $response = Invoke-RestMethod -Uri $searchUrl -Method Get -Headers $headers
    
    if ($response.Count -eq 0) {
        Write-Host "Aucun dashboard trouvé." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "`n✅ $($response.Count) dashboard(s) trouvé(s) :`n" -ForegroundColor Green
    
    # Afficher les informations de chaque dashboard
    foreach ($dashboard in $response) {
        Write-Host "📊 Dashboard: $($dashboard.title)" -ForegroundColor Cyan
        Write-Host "   UID: $($dashboard.uid)" -ForegroundColor Gray
        Write-Host "   URL: $GrafanaUrl/d/$($dashboard.uid)" -ForegroundColor Gray
        Write-Host "   Tags: $($dashboard.tags -join ', ')" -ForegroundColor Gray
        Write-Host "   Type: $($dashboard.type)" -ForegroundColor Gray
        Write-Host ""
    }
    
    # Rechercher spécifiquement les dashboards Beelzebub
    Write-Host "`n=== Dashboards Beelzebub ===" -ForegroundColor Cyan
    $beelzebubDashboards = $response | Where-Object { 
        $_.title -like "*beelzebub*" -or 
        $_.title -like "*monitoring*" -or 
        $_.title -like "*exploit*" -or
        $_.tags -contains "beelzebub" -or
        $_.tags -contains "monitoring"
    }
    
    if ($beelzebubDashboards) {
        Write-Host "`n✅ $($beelzebubDashboards.Count) dashboard(s) Beelzebub trouvé(s) :`n" -ForegroundColor Green
        foreach ($db in $beelzebubDashboards) {
            Write-Host "   - $($db.title) (UID: $($db.uid))" -ForegroundColor Green
        }
    } else {
        Write-Host "Aucun dashboard Beelzebub trouvé." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erreur lors de la récupération des dashboards :" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Vérifiez :" -ForegroundColor Yellow
    Write-Host "  1. L'URL de Grafana est correcte : $GrafanaUrl"
    Write-Host "  2. Le token API a les permissions 'dashboards:read'"
    Write-Host "  3. Grafana est accessible depuis votre machine"
    exit 1
}

Write-Host "`n=== Utilisation MCP Grafana ===" -ForegroundColor Cyan
Write-Host "Si les outils MCP Grafana sont disponibles, vous pouvez utiliser :"
Write-Host '  "List all available dashboards via MCP"'
Write-Host '  "Search dashboards with tag beelzebub"'
Write-Host '  "Get dashboard details for beelzebub-overview"'

# Script pour lister tous les dashboards Grafana
# Usage: .\list-all-dashboards.ps1
# Configurez les variables ci-dessous avant utilisation

param(
    [string]$GrafanaUrl = "",
    [string]$ApiKey = ""
)

if ([string]::IsNullOrEmpty($GrafanaUrl) -or [string]::IsNullOrEmpty($ApiKey)) {
    Write-Host "Usage: .\list-all-dashboards.ps1 -GrafanaUrl 'https://your-grafana-url' -ApiKey 'your-api-key'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}
$allDashboards = Invoke-RestMethod -Uri "$GrafanaUrl/api/search?type=dash-db" -Method Get -Headers $headers

Write-Host ""
Write-Host "=== TOUS LES DASHBOARDS ===" -ForegroundColor Cyan
Write-Host "Total: $($allDashboards.Count) dashboard(s)" -ForegroundColor Green
Write-Host ""

foreach ($db in $allDashboards) {
    Write-Host "📊 $($db.title)" -ForegroundColor Yellow
    Write-Host "   UID: $($db.uid)" -ForegroundColor Gray
    Write-Host "   URL: $GrafanaUrl$($db.url)" -ForegroundColor Gray
    if ($db.tags.Count -gt 0) {
        $tagsStr = $db.tags -join ", "
        Write-Host "   Tags: $tagsStr" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host ""
Write-Host "=== DASHBOARDS BEELZEBUB ===" -ForegroundColor Cyan
$beelzebubDashboards = $allDashboards | Where-Object { 
    $_.title -like "*beelzebub*" -or 
    $_.title -like "*monitoring*" -or 
    $_.title -like "*exploit*" -or
    ($_.tags -contains "beelzebub")
}

Write-Host "Trouvé: $($beelzebubDashboards.Count) dashboard(s)" -ForegroundColor Green
Write-Host ""

foreach ($db in $beelzebubDashboards) {
    Write-Host "✅ $($db.title)" -ForegroundColor Green
    Write-Host "   UID: $($db.uid)" -ForegroundColor Gray
    Write-Host "   URL: $GrafanaUrl$($db.url)" -ForegroundColor Gray
    if ($db.tags.Count -gt 0) {
        $tagsStr = $db.tags -join ", "
        Write-Host "   Tags: $tagsStr" -ForegroundColor Gray
    }
    Write-Host ""
}

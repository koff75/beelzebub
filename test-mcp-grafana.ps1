# Script de test pour les outils MCP Grafana
# Ce script montre comment utiliser get_datasource_by_uid et get_dashboard_property

Write-Host "=== Test des Outils MCP Grafana ===" -ForegroundColor Cyan
Write-Host ""

# Liste des datasources à vérifier
$datasources = @("prometheus", "loki", "tempo")

# Liste des dashboards à vérifier (UIDs à confirmer dans Grafana)
$dashboards = @(
    "beelzebub-overview",
    "beelzebub-ip-analysis", 
    "beelzebub-exploit-detection"
)

Write-Host "1. Vérification des Datasources" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow

foreach ($ds_uid in $datasources) {
    Write-Host "`nVérification du datasource: $ds_uid" -ForegroundColor Green
    
    # Exemple d'utilisation de get_datasource_by_uid
    # Note: Cette commande doit être exécutée via MCP Grafana
    Write-Host "  Commande MCP: get_datasource_by_uid(uid=`"$ds_uid`")"
    Write-Host "  Résultat attendu:"
    Write-Host "    - Nom du datasource"
    Write-Host "    - Type (Prometheus/Loki/Tempo)"
    Write-Host "    - URL de connexion"
    Write-Host "    - UID réel"
    Write-Host "    - Statut de connexion"
}

Write-Host "`n`n2. Vérification des Dashboards" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow

foreach ($dashboard_uid in $dashboards) {
    Write-Host "`nDashboard: $dashboard_uid" -ForegroundColor Green
    
    # Exemples d'utilisation de get_dashboard_property
    Write-Host "  a) Titre du dashboard:"
    Write-Host "     get_dashboard_property(dashboard_uid=`"$dashboard_uid`", jsonpath=`"`$.title`")"
    
    Write-Host "  b) Variables de template:"
    Write-Host "     get_dashboard_property(dashboard_uid=`"$dashboard_uid`", jsonpath=`"`$.templating.list`")"
    
    Write-Host "  c) Datasources utilisées:"
    Write-Host "     get_dashboard_property(dashboard_uid=`"$dashboard_uid`", jsonpath=`"`$.panels[*].datasource`")"
    
    Write-Host "  d) Titres des panneaux:"
    Write-Host "     get_dashboard_property(dashboard_uid=`"$dashboard_uid`", jsonpath=`"`$.panels[*].title`")"
}

Write-Host "`n`n=== Instructions ===" -ForegroundColor Cyan
Write-Host "Pour utiliser ces outils MCP Grafana dans Cursor/Claude:"
Write-Host "1. Assurez-vous que le MCP Grafana est configuré et connecté"
Write-Host "2. Utilisez les commandes ci-dessus dans une conversation avec l'IA"
Write-Host "3. L'IA pourra alors exécuter ces commandes et récupérer les informations"
Write-Host ""
Write-Host "Exemple de requête à faire à l'IA:"
Write-Host '  "Utilise get_datasource_by_uid pour vérifier l''UID de Prometheus"'
Write-Host '  "Utilise get_dashboard_property pour extraire le titre du dashboard beelzebub-overview"'

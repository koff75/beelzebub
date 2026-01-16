#!/bin/bash
# Script de configuration Grafana/Prometheus/Loki pour Railway

set -e

echo "🚀 Configuration des services d'observabilité pour Beelzebub sur Railway"

# Vérifier que Railway CLI est installé
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI n'est pas installé"
    exit 1
fi

# Vérifier que le projet est lié
if ! railway status &> /dev/null; then
    echo "❌ Aucun projet Railway n'est lié. Exécutez: railway link"
    exit 1
fi

echo "✅ Projet Railway lié: $(railway status | grep Project | awk '{print $2}')"

# Configuration Prometheus
echo ""
echo "📊 Configuration Prometheus..."
echo "Pour configurer Prometheus sur Railway:"
echo "1. Allez dans le service Prometheus sur Railway"
echo "2. Ajoutez la variable d'environnement:"
echo "   PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml"
echo "3. Montez le fichier prometheus-config/prometheus.yml"
echo "   OU copiez son contenu dans les variables d'environnement"
echo ""
echo "Configuration Prometheus pour scraper beelzebub:"
echo "  Target: beelzebub:8080/metrics"
echo "  (ou utilisez l'URL publique: https://3il-ingenieurs.site/metrics)"

# Configuration Loki
echo ""
echo "📝 Configuration Loki..."
echo "Pour configurer Loki sur Railway:"
echo "1. Allez dans le service Loki sur Railway"
echo "2. Montez les fichiers de configuration:"
echo "   - loki-config/loki-config.yaml"
echo "   - loki-config/promtail-config.yaml"
echo "3. Déployez Promtail comme service séparé si nécessaire"

# Configuration Grafana
echo ""
echo "📈 Configuration Grafana..."
echo "Pour configurer Grafana sur Railway:"
echo "1. Accédez à Grafana (généralement via le domaine Railway)"
echo "2. Ajoutez les datasources:"
echo "   - Prometheus: http://prometheus:9090 (UID: prometheus)"
echo "   - Loki: http://loki:3100 (UID: loki)"
echo "3. Importez les dashboards depuis grafana-dashboards/"

# Variables d'environnement recommandées
echo ""
echo "🔧 Variables d'environnement recommandées pour beelzebub:"
echo "  PORT=8080"
echo "  OPEN_AI_SECRET_KEY=<votre-clé>"

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📚 Consultez GRAFANA_SETUP.md pour les instructions détaillées"

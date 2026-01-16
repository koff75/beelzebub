# Déploiement Grafana/Prometheus/Loki sur Railway

Guide de déploiement des services d'observabilité pour Beelzebub sur Railway.

## Prérequis

- Projet Railway `zoological-dedication` avec les services : Prometheus, Loki, Grafana, beelzebub
- Railway CLI installé et authentifié
- Accès aux services Railway

## 1. Configuration Prometheus

### Option A : Via variables d'environnement (Recommandé)

1. **Lier le service Prometheus :**
   ```bash
   railway service prometheus
   ```

2. **Ajouter la configuration :**
   - Allez dans l'onglet **Variables** du service Prometheus
   - Ajoutez la variable `PROMETHEUS_CONFIG` avec le contenu de `railway-prometheus-config.yml`
   - OU montez le fichier `railway-prometheus-config.yml` dans le service

3. **Vérifier la configuration :**
   - Accédez à Prometheus : `https://prometheus-production.up.railway.app`
   - Vérifiez les targets : `/targets`
   - Le target `beelzebub` doit être `UP`

### Option B : Via fichier monté

1. **Créer un volume ou ConfigMap avec le fichier de configuration**
2. **Monter le fichier** dans le service Prometheus
3. **Redémarrer le service**

## 2. Configuration Loki

### Option A : Via Promtail (Recommandé)

1. **Déployer Promtail comme service séparé :**
   ```bash
   railway service create promtail
   ```

2. **Configurer Promtail :**
   - Utilisez l'image Docker : `grafana/promtail:latest`
   - Montez le fichier `loki-config/promtail-config.yaml`
   - Configurez les variables d'environnement :
     ```
     LOKI_URL=http://loki:3100
     ```

3. **Collecter les logs Railway :**
   - Promtail peut collecter les logs via l'API Railway
   - Ou depuis les fichiers de logs si montés

### Option B : Configuration directe Loki

1. **Lier le service Loki :**
   ```bash
   railway service loki
   ```

2. **Configurer Loki :**
   - Montez le fichier `loki-config/loki-config.yaml`
   - Configurez les variables d'environnement nécessaires

## 3. Configuration Grafana

### 3.1 Ajouter les datasources

1. **Accéder à Grafana :**
   - URL : Généralement `https://grafana-production.up.railway.app`
   - Identifiants par défaut : `admin` / `admin` (à changer)

2. **Ajouter Prometheus :**
   - Configuration > Data sources > Add data source > Prometheus
   - URL : `http://prometheus:9090` (interne) ou `https://prometheus-production.up.railway.app` (externe)
   - **UID important :** `prometheus` (pour les dashboards)
   - Save & Test

3. **Ajouter Loki :**
   - Configuration > Data sources > Add data source > Loki
   - URL : `http://loki:3100` (interne) ou `https://loki-production.up.railway.app` (externe)
   - **UID important :** `loki` (pour les dashboards)
   - Save & Test

### 3.2 Importer les dashboards

1. **Méthode 1 : Import JSON**
   - Dashboards > Import
   - Cliquez sur "Upload JSON file"
   - Importez les 3 fichiers :
     - `grafana-dashboards/beelzebub-overview.json`
     - `grafana-dashboards/beelzebub-exploit-detection.json`
     - `grafana-dashboards/beelzebub-ip-analysis.json`

2. **Méthode 2 : Copier-coller**
   - Dashboards > Import
   - Collez le contenu JSON de chaque fichier
   - Cliquez sur "Load"

3. **Vérifier les dashboards :**
   - Ouvrez chaque dashboard
   - Vérifiez que les panels affichent des données
   - Si vides, vérifiez les datasources (UIDs doivent être `prometheus` et `loki`)

## 4. Configuration via Railway CLI

### Variables d'environnement pour Prometheus

```bash
# Lier le service Prometheus
railway service prometheus

# Ajouter la configuration (si supporté)
railway variables --set "PROMETHEUS_CONFIG=$(cat railway-prometheus-config.yml)"
```

### Variables d'environnement pour Loki

```bash
# Lier le service Loki
railway service loki

# Configurer l'URL de Loki pour Promtail
railway variables --set "LOKI_URL=http://loki:3100"
```

### Variables d'environnement pour Grafana

```bash
# Lier le service Grafana
railway service grafana

# Configurer les datasources (si via variables)
railway variables --set "GF_DATASOURCES_PROMETHEUS_URL=http://prometheus:9090"
railway variables --set "GF_DATASOURCES_LOKI_URL=http://loki:3100"
```

## 5. Vérification

### Vérifier Prometheus

1. Accédez à Prometheus : `https://prometheus-production.up.railway.app`
2. Testez une requête : `beelzebub_events_total`
3. Vérifiez les targets : `/targets` - `beelzebub` doit être `UP`

### Vérifier Loki

1. Accédez à Loki : `https://loki-production.up.railway.app`
2. Testez une requête LogQL : `{service="beelzebub"}`
3. Vérifiez que les logs sont collectés

### Vérifier Grafana

1. Accédez à Grafana
2. Vérifiez les datasources : Configuration > Data sources
3. Testez les requêtes dans Explore :
   - Prometheus : `beelzebub_events_total`
   - Loki : `{service="beelzebub"} |= "HTTP New request"`

## 6. URLs des services Railway

Sur Railway, les services ont généralement des URLs du type :
- `https://prometheus-production.up.railway.app`
- `https://loki-production.up.railway.app`
- `https://grafana-production.up.railway.app`
- `https://3il-ingenieurs.site` (beelzebub)

Pour la communication interne entre services, utilisez les noms de service :
- `http://prometheus:9090`
- `http://loki:3100`
- `http://grafana:3000`

## 7. Dépannage

### Prometheus ne scrape pas beelzebub

1. Vérifiez que beelzebub expose `/metrics` : `https://3il-ingenieurs.site/metrics`
2. Vérifiez la configuration du target dans Prometheus
3. Vérifiez les logs Prometheus : `railway logs --service prometheus`

### Loki ne collecte pas les logs

1. Vérifiez que Promtail est déployé et fonctionne
2. Vérifiez la connectivité entre Promtail et Loki
3. Vérifiez les logs Loki : `railway logs --service loki`

### Les dashboards sont vides

1. Vérifiez les datasources (UIDs doivent être `prometheus` et `loki`)
2. Testez les requêtes directement dans Explore
3. Vérifiez que les données sont disponibles

## 8. Commandes utiles

```bash
# Voir les services
railway service

# Voir les logs
railway logs --service beelzebub
railway logs --service prometheus
railway logs --service loki

# Voir les variables
railway variables

# Déployer
railway up
```

## 9. Prochaines étapes

1. ✅ Configurer Prometheus pour scraper beelzebub
2. ✅ Configurer Loki pour collecter les logs
3. ✅ Importer les dashboards dans Grafana
4. ✅ Configurer les alertes (optionnel)
5. ✅ Optimiser les performances

## 10. Support

Pour toute question :
- Consultez `GRAFANA_SETUP.md` pour les détails techniques
- Vérifiez les logs Railway
- Testez les requêtes directement dans Prometheus/Loki

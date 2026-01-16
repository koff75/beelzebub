# Guide de Déploiement Railway - Grafana/Prometheus/Loki

Guide étape par étape pour configurer l'observabilité Beelzebub sur Railway.

## 🎯 Objectif

Configurer Prometheus, Loki et Grafana pour visualiser les métriques et logs du honeypot Beelzebub.

## 📋 Étape 1 : Vérifier les services

1. Allez sur [Railway Dashboard](https://railway.app)
2. Sélectionnez le projet `zoological-dedication`
3. Vérifiez que les services suivants existent :
   - ✅ Prometheus
   - ✅ Loki
   - ✅ Grafana
   - ✅ beelzebub

## 📊 Étape 2 : Configurer Prometheus

### 2.1 Accéder au service Prometheus

1. Cliquez sur le service **Prometheus** dans Railway
2. Allez dans l'onglet **Variables**

### 2.2 Configurer le scraping de beelzebub

**Option A : Via l'interface Railway (Recommandé)**

1. Si Prometheus est déployé via un template Railway, il peut avoir une interface de configuration
2. Ajoutez un nouveau target :
   - **Job name** : `beelzebub`
   - **Target URL** : `https://3il-ingenieurs.site/metrics`
   - **Scrape interval** : `15s`

**Option B : Via fichier de configuration**

1. Dans le service Prometheus, allez dans **Settings** > **Volumes**
2. Créez un volume et montez le fichier `railway-prometheus-config.yml`
3. Configurez la variable d'environnement :
   ```
   PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml
   ```

### 2.3 Vérifier la configuration

1. Accédez à Prometheus : `https://prometheus-production.up.railway.app`
2. Allez dans **Status** > **Targets**
3. Vérifiez que le target `beelzebub` est `UP`
4. Testez une requête : `beelzebub_events_total`

## 📝 Étape 3 : Configurer Loki

### 3.1 Accéder au service Loki

1. Cliquez sur le service **Loki** dans Railway
2. Allez dans l'onglet **Variables**

### 3.2 Configurer la collecte de logs

**Option A : Via Promtail (Recommandé)**

1. **Créer un nouveau service Promtail :**
   - Cliquez sur **+ New** > **Empty Service**
   - Nommez-le `promtail`
   - Utilisez l'image : `grafana/promtail:latest`

2. **Configurer Promtail :**
   - Montez le fichier `loki-config/promtail-config.yaml`
   - Ajoutez les variables :
     ```
     LOKI_URL=http://loki:3100
     ```

**Option B : Configuration directe Loki**

1. Montez le fichier `loki-config/loki-config.yaml` dans le service Loki
2. Redémarrez le service

### 3.3 Vérifier la configuration

1. Accédez à Loki : `https://loki-production.up.railway.app`
2. Testez une requête LogQL : `{service="beelzebub"}`
3. Vérifiez que les logs sont collectés

## 📈 Étape 4 : Configurer Grafana

### 4.1 Accéder à Grafana

1. Cliquez sur le service **Grafana** dans Railway
2. Notez l'URL publique (ex: `https://grafana-production.up.railway.app`)
3. Accédez à Grafana dans votre navigateur
4. Identifiants par défaut : `admin` / `admin` (changez-les !)

### 4.2 Ajouter les datasources

#### Datasource Prometheus

1. Allez dans **Configuration** > **Data sources**
2. Cliquez sur **Add data source**
3. Sélectionnez **Prometheus**
4. Configurez :
   - **URL** : `http://prometheus:9090` (interne) ou `https://prometheus-production.up.railway.app` (externe)
   - **UID** : `prometheus` ⚠️ **IMPORTANT pour les dashboards**
   - **Access** : Server (default)
5. Cliquez sur **Save & Test**

#### Datasource Loki

1. Cliquez sur **Add data source**
2. Sélectionnez **Loki**
3. Configurez :
   - **URL** : `http://loki:3100` (interne) ou `https://loki-production.up.railway.app` (externe)
   - **UID** : `loki` ⚠️ **IMPORTANT pour les dashboards**
   - **Access** : Server (default)
4. Cliquez sur **Save & Test**

### 4.3 Importer les dashboards

#### Dashboard 1 : Beelzebub Overview

1. Allez dans **Dashboards** > **Import**
2. Cliquez sur **Upload JSON file**
3. Sélectionnez `grafana-dashboards/beelzebub-overview.json`
4. Vérifiez que les datasources sont correctement sélectionnés
5. Cliquez sur **Import**

#### Dashboard 2 : Exploit Detection

1. Répétez les étapes pour `grafana-dashboards/beelzebub-exploit-detection.json`

#### Dashboard 3 : IP Analysis

1. Répétez les étapes pour `grafana-dashboards/beelzebub-ip-analysis.json`

### 4.4 Vérifier les dashboards

1. Ouvrez chaque dashboard
2. Vérifiez que les panels affichent des données
3. Si des panels sont vides :
   - Vérifiez les datasources (UIDs doivent être `prometheus` et `loki`)
   - Testez les requêtes dans **Explore**
   - Vérifiez que les données sont disponibles

## 🔧 Étape 5 : Configuration avancée (Optionnel)

### 5.1 Alertes Prometheus

1. Créez un fichier `prometheus-alerts.yml` avec les règles d'alerte
2. Montez-le dans Prometheus
3. Configurez Alertmanager si nécessaire

### 5.2 Alertes Grafana

1. Dans Grafana, créez des alertes pour :
   - Taux d'événements anormal
   - Détection d'exploitation CVE-2026-21858
   - IPs avec comportement suspect

### 5.3 Optimisation

1. Ajustez les intervalles de scrape selon vos besoins
2. Configurez la rétention des données
3. Optimisez les requêtes LogQL

## ✅ Vérification finale

### Checklist

- [ ] Prometheus scrape les métriques de beelzebub
- [ ] Loki collecte les logs
- [ ] Grafana a les datasources configurés (UIDs corrects)
- [ ] Les 3 dashboards sont importés et fonctionnent
- [ ] Les panels affichent des données

### Tests

1. **Test Prometheus :**
   ```promql
   beelzebub_events_total
   rate(beelzebub_http_events_total[1m]) * 60
   ```

2. **Test Loki :**
   ```logql
   {service="beelzebub"} |= "HTTP New request"
   topk(10, sum by (source_ip) (count_over_time({service="beelzebub"}[1h])))
   ```

3. **Test Grafana :**
   - Ouvrez le dashboard "Beelzebub Overview"
   - Vérifiez que les métriques s'affichent
   - Vérifiez que les logs s'affichent

## 🐛 Dépannage

### Prometheus ne scrape pas beelzebub

1. Vérifiez que beelzebub expose `/metrics` : `https://3il-ingenieurs.site/metrics`
2. Vérifiez la configuration du target dans Prometheus
3. Vérifiez les logs : `railway logs --service prometheus`

### Loki ne collecte pas les logs

1. Vérifiez que Promtail est déployé et fonctionne
2. Vérifiez la connectivité entre Promtail et Loki
3. Vérifiez les logs : `railway logs --service loki`

### Les dashboards sont vides

1. Vérifiez les datasources (UIDs doivent être `prometheus` et `loki`)
2. Testez les requêtes dans **Explore**
3. Vérifiez que les données sont disponibles

## 📚 Ressources

- [GRAFANA_SETUP.md](GRAFANA_SETUP.md) - Guide technique détaillé
- [RAILWAY_GRAFANA_DEPLOY.md](RAILWAY_GRAFANA_DEPLOY.md) - Guide de déploiement Railway
- [Documentation Railway](https://docs.railway.app)

## 🎉 Félicitations !

Votre stack d'observabilité est maintenant configurée ! Vous pouvez :
- Visualiser les métriques en temps réel
- Analyser les logs structurés
- Détecter les tentatives d'exploitation
- Analyser le comportement des IPs

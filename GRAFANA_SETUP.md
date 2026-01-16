# Guide de Configuration Grafana pour Beelzebub

Ce guide explique comment configurer Prometheus, Loki et Grafana pour visualiser les métriques et logs du honeypot Beelzebub avec des dashboards de corrélation.

## Architecture

```
┌─────────────┐
│  beelzebub  │─── Métriques ───> Prometheus ───┐
│  (port 8080)│─── Logs ───────> Loki ─────────┤
│             │                                 │
└─────────────┘                                 │
                                                ▼
                                          ┌──────────┐
                                          │ Grafana  │
                                          │(Dashboards)│
                                          └──────────┘
```

## Prérequis

- Services Railway déployés : Prometheus, Loki, Grafana
- Service beelzebub déployé et fonctionnel
- Accès aux services Railway pour la configuration

## 1. Configuration Prometheus

### 1.1 Fichier de configuration

Le fichier `prometheus-config/prometheus.yml` contient la configuration pour scraper les métriques de beelzebub.

### 1.2 Configuration sur Railway

**Option A : Via variables d'environnement Railway**

1. Dans le service Prometheus sur Railway, ajoutez les variables :
   ```
   PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml
   ```

2. Montez le fichier de configuration :
   - Utilisez un volume ou un ConfigMap
   - Ou copiez le contenu dans les variables d'environnement

**Option B : Configuration directe**

1. Connectez-vous au service Prometheus sur Railway
2. Modifiez la configuration pour inclure le job `beelzebub`
3. Utilisez l'URL interne Railway : `beelzebub:8080/metrics`

### 1.3 Vérification

Vérifiez que Prometheus scrape les métriques :
- Accédez à Prometheus : `http://prometheus:9090/targets`
- Vérifiez que le target `beelzebub` est `UP`
- Testez une requête : `beelzebub_events_total`

## 2. Configuration Loki

### 2.1 Fichiers de configuration

- `loki-config/loki-config.yaml` : Configuration principale de Loki
- `loki-config/promtail-config.yaml` : Configuration Promtail pour collecter les logs

### 2.2 Configuration sur Railway

**Option A : Collecte via Promtail**

1. Déployez Promtail comme service séparé sur Railway
2. Configurez Promtail avec `promtail-config.yaml`
3. Promtail collectera les logs Railway et les enverra à Loki

**Option B : Collecte directe depuis Railway**

1. Configurez Loki pour recevoir les logs directement depuis Railway
2. Utilisez l'API Railway pour streamer les logs vers Loki
3. Configurez un webhook ou un endpoint pour recevoir les logs

### 2.3 Format des logs Beelzebub

Les logs Beelzebub sont au format JSON structuré :

```json
{
  "level": "info",
  "msg": "HTTP New request",
  "event": {
    "ID": "de090320-2b3b-440a-a75d-4d0750d55350",
    "SourceIp": "193.19.82.13",
    "HTTPMethod": "HEAD",
    "RequestURI": "/",
    "UserAgent": "Mozilla/5.0...",
    "Handler": "n8n Homepage SEO",
    "Body": "...",
    "Headers": {...}
  }
}
```

### 2.4 Pipeline de parsing

Le pipeline Promtail extrait automatiquement :
- Labels : `source_ip`, `http_method`, `request_uri`, `user_agent`, `handler`, `protocol`
- Détection d'exploits : Label `exploit_attempt=cve-2026-21858` pour les requêtes avec `filepath`

### 2.5 Vérification

Vérifiez que Loki collecte les logs :
- Accédez à Loki : `http://loki:3100/ready`
- Testez une requête LogQL : `{service="beelzebub"} |= "HTTP New request"`

## 3. Configuration Grafana

### 3.1 Ajout des datasources

1. Accédez à Grafana : `http://grafana:3000`
2. Allez dans **Configuration** > **Data sources**
3. Ajoutez **Prometheus** :
   - URL : `http://prometheus:9090`
   - UID : `prometheus` (important pour les dashboards)
4. Ajoutez **Loki** :
   - URL : `http://loki:3100`
   - UID : `loki` (important pour les dashboards)

### 3.2 Import des dashboards

1. Allez dans **Dashboards** > **Import**
2. Importez les 3 dashboards JSON :
   - `grafana-dashboards/beelzebub-overview.json`
   - `grafana-dashboards/beelzebub-exploit-detection.json`
   - `grafana-dashboards/beelzebub-ip-analysis.json`

**Méthode alternative :**
- Copiez le contenu JSON de chaque fichier
- Collez-le dans l'éditeur JSON de Grafana
- Cliquez sur **Load**

### 3.3 Vérification des dashboards

1. Ouvrez chaque dashboard
2. Vérifiez que les panels affichent des données
3. Si des panels sont vides, vérifiez :
   - Les datasources sont correctement configurés
   - Les UIDs des datasources correspondent (`prometheus`, `loki`)
   - Les métriques/logs sont disponibles

## 4. Dashboards disponibles

### 4.1 Beelzebub Overview

**Panels principaux :**
- **Total Events** : Nombre total d'événements capturés
- **Events by Protocol** : Répartition HTTP/SSH/TCP/MCP
- **HTTP Events Rate** : Taux d'événements HTTP par minute
- **Top 10 Source IPs** : IPs les plus actives
- **Top 10 Endpoints** : Endpoints les plus ciblés
- **Top 10 User-Agents** : User-Agents les plus fréquents
- **HTTP Methods Distribution** : Répartition GET/POST/HEAD/etc.
- **Events Timeline** : Graphique temporel des événements
- **Recent Events Log** : Logs récents en temps réel

**Utilisation :**
- Vue d'ensemble de l'activité du honeypot
- Identification des patterns d'attaque
- Surveillance en temps réel

### 4.2 Exploit Detection (CVE-2026-21858)

**Panels principaux :**
- **Exploit Attempts Detected** : Nombre de tentatives d'exploitation
- **Exploit Attempts Rate** : Taux de tentatives par heure
- **POST /form/* Requests with filepath** : Table des tentatives d'exploitation
- **IPs Attempting Exploitation** : IPs sources des exploits
- **Suspicious Requests** : Requêtes avec Content-Type: application/json vers /form/*
- **Exploitation Request Bodies** : Corps des requêtes d'exploitation
- **Suspicious User-Agents** : User-Agents suspects (scanners)
- **Exploitation Headers** : En-têtes des requêtes d'exploitation

**Utilisation :**
- Détection en temps réel des tentatives d'exploitation CVE-2026-21858
- Analyse des payloads d'exploitation
- Identification des attaquants

### 4.3 IP Analysis

**Panels principaux :**
- **Most Active IPs** : Top 20 IPs les plus actives
- **Requests per IP (Timeline)** : Graphique temporel par IP
- **Endpoints Targeted by IP (Heatmap)** : Heatmap IP/Endpoint
- **User-Agents by IP** : User-Agents utilisés par chaque IP
- **IPs with Abnormal Request Rate** : IPs avec taux anormal
- **IPs Targeting Specific Endpoints** : IPs ciblant /form/*
- **Suspicious Patterns** : Patterns suspects détectés
- **IP Activity Timeline** : Timeline d'activité des top IPs
- **Detailed IP Information** : Logs détaillés par IP

**Utilisation :**
- Analyse comportementale des IPs
- Détection d'anomalies
- Corrélation IP/Endpoint/User-Agent

## 5. Requêtes PromQL utiles

```promql
# Total événements
beelzebub_events_total

# Rate d'événements HTTP par minute
rate(beelzebub_http_events_total[1m]) * 60

# Événements par protocole
beelzebub_http_events_total
beelzebub_ssh_events_total
beelzebub_tcp_events_total
beelzebub_mcp_events_total

# Augmentation d'événements
increase(beelzebub_events_total[1h])
```

## 6. Requêtes LogQL utiles

```logql
# Tous les événements HTTP
{service="beelzebub"} |= "HTTP New request"

# Requêtes POST vers /form/*
{service="beelzebub"} |= "POST" |= "/form/"

# Tentatives d'exploitation CVE-2026-21858
{service="beelzebub"} |= "filepath" |= "/form/"

# Top IPs sources
topk(10, sum by (source_ip) (count_over_time({service="beelzebub"}[1h])))

# Requêtes par endpoint
sum by (request_uri) (count_over_time({service="beelzebub"}[1h]))

# Requêtes avec Content-Type: application/json
{service="beelzebub"} | json | Content-Type="application/json"

# User-Agents suspects
{service="beelzebub"} |~ "(?i)(scanner|bot|crawler|python|curl|wget)"
```

## 7. Alertes recommandées

### 7.1 Alertes Prometheus

```yaml
groups:
  - name: beelzebub
    rules:
      - alert: HighEventRate
        expr: rate(beelzebub_events_total[5m]) > 100
        for: 5m
        annotations:
          summary: "Taux d'événements anormalement élevé"
      
      - alert: ExploitDetected
        expr: count_over_time({service="beelzebub"} |= "filepath" [5m]) > 0
        for: 1m
        annotations:
          summary: "Tentative d'exploitation CVE-2026-21858 détectée"
```

### 7.2 Alertes Grafana

1. Dans Grafana, créez des alertes pour :
   - Taux d'événements anormal
   - Détection d'exploitation
   - IPs avec comportement suspect
   - Erreurs dans les logs

## 8. Dépannage

### 8.1 Prometheus ne scrape pas les métriques

- Vérifiez que beelzebub expose `/metrics` sur le port 8080
- Vérifiez la connectivité réseau entre Prometheus et beelzebub
- Vérifiez la configuration du job dans `prometheus.yml`
- Consultez les logs Prometheus : `railway logs --service prometheus`

### 8.2 Loki ne collecte pas les logs

- Vérifiez que Promtail est déployé et configuré
- Vérifiez la connectivité entre Promtail et Loki
- Vérifiez le format des logs (doivent être JSON)
- Consultez les logs Loki : `railway logs --service loki`

### 8.3 Les dashboards sont vides

- Vérifiez que les datasources sont correctement configurés
- Vérifiez les UIDs des datasources (`prometheus`, `loki`)
- Testez les requêtes PromQL/LogQL directement
- Vérifiez que les données sont disponibles dans Prometheus/Loki

### 8.4 Les requêtes LogQL ne fonctionnent pas

- Vérifiez que les labels sont correctement extraits
- Vérifiez le format JSON des logs
- Testez avec des requêtes simples : `{service="beelzebub"}`
- Consultez la documentation LogQL : https://grafana.com/docs/loki/latest/logql/

## 9. Optimisation

### 9.1 Performance

- Ajustez les intervalles de scrape selon vos besoins
- Limitez le nombre de labels pour réduire la cardinalité
- Utilisez des requêtes LogQL optimisées
- Configurez la rétention des données

### 9.2 Coûts

- Surveillez l'utilisation du stockage
- Configurez la rétention appropriée
- Utilisez des agrégations pour réduire les données

## 10. Ressources supplémentaires

- [Documentation Prometheus](https://prometheus.io/docs/)
- [Documentation Loki](https://grafana.com/docs/loki/latest/)
- [Documentation Grafana](https://grafana.com/docs/grafana/latest/)
- [Guide LogQL](https://grafana.com/docs/loki/latest/logql/)
- [Guide PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/)

## 11. Support

Pour toute question ou problème :
1. Consultez les logs des services Railway
2. Vérifiez la documentation officielle
3. Testez les requêtes directement dans Prometheus/Loki
4. Vérifiez la configuration des datasources dans Grafana

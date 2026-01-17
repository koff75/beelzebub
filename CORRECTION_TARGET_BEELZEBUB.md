# 🔧 Correction : Target beelzebub manquant dans Prometheus

## ❌ Problème Détecté

Dans Prometheus UI, seul le target `prometheus` (auto-scraping) est visible. Le target `beelzebub` n'apparaît pas.

**Targets visibles :**
- ✅ `prometheus` (localhost:9090) - UP
- ❌ `beelzebub` - **MANQUANT**

## 🔍 Analyse

### Cause Probable

Prometheus charge le fichier `/etc/prometheus/prom.yml` (d'après les logs), mais ce fichier ne contient probablement pas la configuration pour scraper beelzebub.

**Variables configurées :**
- `PROMETHEUS_TARGETS=https://3il-ingenieurs.site/metrics` ✅
- `PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml` ✅

**Mais :**
- Prometheus charge `/etc/prometheus/prom.yml` (pas `/prometheus/prometheus.yml`)
- Le fichier `/etc/prometheus/prom.yml` ne contient probablement pas le target beelzebub

## 🔧 Solutions

### Solution 1 : Ajouter le fichier de configuration au volume (Recommandé)

Le fichier `railway-prometheus-config.yml` doit être ajouté au volume Prometheus.

**Dans Railway Dashboard :**
1. Allez dans **Prometheus** > **Settings** > **Volumes**
2. Le volume `prometheus-volume-Yzvy` est monté à `/prometheus`
3. Ajoutez le fichier `railway-prometheus-config.yml` au volume
4. Renommez-le en `prometheus.yml` OU créez un symlink vers `/etc/prometheus/prom.yml`

**OU modifiez le Dockerfile de Prometheus :**
```dockerfile
COPY railway-prometheus-config.yml /etc/prometheus/prom.yml
```

### Solution 2 : Modifier directement le fichier dans le volume

Si vous avez accès au volume, modifiez `/etc/prometheus/prom.yml` pour ajouter :

```yaml
scrape_configs:
  # Scrape beelzebub metrics
  - job_name: 'beelzebub'
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: '/metrics'
    static_configs:
      - targets:
          - '3il-ingenieurs.site'
    scheme: 'https'
    tls_config:
      insecure_skip_verify: false
    relabel_configs:
      - target_label: service
        replacement: 'beelzebub'
      - target_label: environment
        replacement: 'production'
      - target_label: honeypot_type
        replacement: 'n8n'

  # Scrape Prometheus lui-même (déjà présent)
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### Solution 3 : Utiliser les variables d'environnement (si supporté)

Si votre image Prometheus supporte les variables d'environnement pour les targets, vérifiez que `PROMETHEUS_TARGETS` est bien utilisé.

## ✅ Actions Immédiates

### Étape 1 : Vérifier le contenu actuel de `/etc/prometheus/prom.yml`

Si possible, vérifiez ce que contient le fichier actuel.

### Étape 2 : Ajouter la configuration beelzebub

**Option A : Via Railway Dashboard (Recommandé)**
1. Allez dans **Prometheus** > **Settings** > **Volumes**
2. Ajoutez/modifiez le fichier de configuration
3. Redémarrez Prometheus

**Option B : Via Dockerfile**
1. Modifiez le Dockerfile de Prometheus
2. Ajoutez : `COPY railway-prometheus-config.yml /etc/prometheus/prom.yml`
3. Redéployez

### Étape 3 : Redémarrer Prometheus

```bash
# Via Railway Dashboard
# Prometheus > Settings > Restart

# Ou attendez le redéploiement automatique
```

### Étape 4 : Vérifier les Targets

1. Accédez à Prometheus UI
2. Allez dans **Status** > **Targets**
3. Vous devriez voir :
   - ✅ `prometheus` (localhost:9090) - UP
   - ✅ `beelzebub` (3il-ingenieurs.site) - UP

## 📝 Configuration Complète du Fichier

Le fichier `/etc/prometheus/prom.yml` devrait contenir :

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'railway'
    environment: 'production'

scrape_configs:
  # Scrape beelzebub metrics
  - job_name: 'beelzebub'
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: '/metrics'
    static_configs:
      - targets:
          - '3il-ingenieurs.site'
    scheme: 'https'
    tls_config:
      insecure_skip_verify: false
    relabel_configs:
      - target_label: service
        replacement: 'beelzebub'
      - target_label: environment
        replacement: 'production'
      - target_label: honeypot_type
        replacement: 'n8n'

  # Scrape Prometheus lui-même
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

## 🎯 Résultat Attendu

Après correction, dans Prometheus UI > Status > Targets, vous devriez voir :

| Endpoint | Labels | State |
|----------|--------|-------|
| `http://localhost:9090/metrics` | `job="prometheus"` | UP |
| `https://3il-ingenieurs.site/metrics` | `job="beelzebub"` | UP |

## 🐛 Dépannage

### Le target beelzebub est toujours absent

1. Vérifiez que le fichier de configuration a été modifié
2. Vérifiez les logs : `railway logs --service Prometheus`
3. Vérifiez la syntaxe YAML du fichier
4. Redémarrez Prometheus

### Le target beelzebub est DOWN

1. Vérifiez que beelzebub expose `/metrics` : `curl https://3il-ingenieurs.site/metrics`
2. Vérifiez la connectivité réseau
3. Vérifiez les certificats SSL (si erreur TLS)

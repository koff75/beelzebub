# Configuration Prometheus via Volume Railway

## 📊 État actuel

Prometheus a un volume monté à `/prometheus` avec :
- Volume : `prometheus-volume`
- Chemin de montage : `/prometheus`
- Dockerfile : `/prometheus/dockerfile`

## 🎯 Configuration

### Option 1 : Ajouter le fichier de configuration au volume (Recommandé)

1. **Dans Railway Dashboard :**
   - Allez dans **Prometheus** > **Settings** > **Volumes**
   - Le volume `prometheus-volume` est déjà monté à `/prometheus`

2. **Ajouter le fichier de configuration :**
   - Le fichier `railway-prometheus-config.yml` doit être copié dans le volume
   - Chemin dans le conteneur : `/prometheus/prometheus.yml`

3. **Configurer la variable d'environnement :**
   ```bash
   railway variables --set "PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml"
   ```

### Option 2 : Via Railway CLI (si le volume est accessible)

Si vous pouvez accéder au volume via Railway CLI, vous pouvez copier le fichier :

```bash
# Le fichier de configuration est déjà créé : railway-prometheus-config.yml
# Il doit être monté dans le volume à /prometheus/prometheus.yml
```

### Option 3 : Modifier le Dockerfile

Si Prometheus utilise un Dockerfile personnalisé, ajoutez le fichier de configuration :

```dockerfile
COPY railway-prometheus-config.yml /prometheus/prometheus.yml
```

## ✅ Configuration rapide via variables

Comme il y a déjà `RAILWAY_SERVICE_BEELZEBUB_URL=3il-ingenieurs.site`, vous pouvez aussi configurer Prometheus via des variables si votre image le supporte :

```bash
# Ajouter le target beelzebub
railway variables --set "PROMETHEUS_TARGETS=beelzebub:https://3il-ingenieurs.site/metrics"

# Ou utiliser la variable existante
railway variables --set "PROMETHEUS_TARGETS=beelzebub:https://${RAILWAY_SERVICE_BEELZEBUB_URL}/metrics"
```

## 🔧 Configuration recommandée

La méthode la plus fiable est de monter le fichier `railway-prometheus-config.yml` dans le volume `/prometheus` :

1. **Dans Railway Dashboard :**
   - Prometheus > Settings > Volumes
   - Assurez-vous que le volume est monté
   - Ajoutez le fichier `railway-prometheus-config.yml` au volume (renommé en `prometheus.yml`)

2. **Ou via le Dockerfile :**
   - Si vous avez accès au Dockerfile, ajoutez :
   ```dockerfile
   COPY railway-prometheus-config.yml /prometheus/prometheus.yml
   ```

3. **Configurer la variable :**
   ```bash
   railway variables --set "PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml"
   ```

## ✅ Vérification

Une fois configuré :

1. **Redémarrez le service Prometheus** (si nécessaire)
2. **Vérifiez les targets :**
   - Accédez à Prometheus : `https://prometheus-production.up.railway.app`
   - Allez dans **Status** > **Targets**
   - Le target `beelzebub` doit être `UP`

3. **Testez une requête :**
   - Allez dans **Graph**
   - Testez : `beelzebub_events_total`

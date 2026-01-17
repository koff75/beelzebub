# 🔍 Analyse de la Configuration Prometheus sur Railway

## 📊 État Actuel

### Variables Configurées ✅

- ✅ `PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml`
- ⚠️ `PROMETHEUS_TARGETS=beelzebub:8080` (❌ **INCORRECT**)
- ✅ `SCRAPE_INTERVAL=15s`

### Problèmes Détectés

1. **❌ PROMETHEUS_TARGETS incorrect :**
   - Actuel : `beelzebub:8080`
   - Problème : Beelzebub est accessible via HTTPS sur `3il-ingenieurs.site`, pas sur le port 8080 en interne
   - Solution : Utiliser l'URL publique HTTPS

2. **⚠️ Fichier de configuration :**
   - Prometheus charge : `/etc/prometheus/prom.yml` (d'après les logs)
   - Variable configurée : `/prometheus/prometheus.yml`
   - Il faut vérifier si le fichier existe dans le volume

## 🔧 Corrections Nécessaires

### Correction 1 : PROMETHEUS_TARGETS

La variable `PROMETHEUS_TARGETS` doit pointer vers l'URL publique HTTPS :

```bash
railway variables --set "PROMETHEUS_TARGETS=https://3il-ingenieurs.site/metrics"
```

**OU** si Prometheus utilise un format spécifique :

```bash
railway variables --set "PROMETHEUS_TARGETS=beelzebub:https://3il-ingenieurs.site/metrics"
```

### Correction 2 : Vérifier le fichier de configuration

D'après les logs, Prometheus charge `/etc/prometheus/prom.yml`. Il faut :

1. **Vérifier si le fichier existe dans le volume :**
   - Volume monté : `/prometheus`
   - Fichier attendu : `/prometheus/prometheus.yml` OU `/etc/prometheus/prom.yml`

2. **Si le fichier n'existe pas :**
   - Ajouter `railway-prometheus-config.yml` au volume
   - Le renommer en `prometheus.yml` ou `prom.yml` selon ce que Prometheus attend

## ✅ Actions à Effectuer

### Étape 1 : Corriger PROMETHEUS_TARGETS

```bash
# Lier le service Prometheus
railway service Prometheus

# Corriger la variable
railway variables --set "PROMETHEUS_TARGETS=https://3il-ingenieurs.site/metrics"
```

### Étape 2 : Vérifier le fichier de configuration

**Option A : Si Prometheus utilise le fichier de configuration**

1. Dans Railway Dashboard > Prometheus > Settings > Volumes
2. Vérifiez que le fichier `prometheus.yml` (ou `prom.yml`) existe dans le volume
3. Si absent, ajoutez `railway-prometheus-config.yml` au volume

**Option B : Si Prometheus utilise uniquement les variables**

1. La variable `PROMETHEUS_TARGETS` devrait suffire
2. Vérifiez que Prometheus redémarre après la modification

### Étape 3 : Vérifier la configuration

1. **Redémarrez Prometheus** (si nécessaire)
2. **Vérifiez les logs :**
   ```bash
   railway logs --service Prometheus --lines 50
   ```
3. **Vérifiez les targets dans Prometheus UI :**
   - URL : `https://prometheus-production.up.railway.app`
   - Status > Targets
   - Le target `beelzebub` doit être `UP`

## 📝 Configuration Recommandée

### Variables Finales

```bash
PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml
PROMETHEUS_TARGETS=https://3il-ingenieurs.site/metrics
SCRAPE_INTERVAL=15s
```

### Fichier de Configuration (si nécessaire)

Le fichier `railway-prometheus-config.yml` doit être dans le volume à :
- `/prometheus/prometheus.yml` OU
- `/etc/prometheus/prom.yml` (selon la configuration Prometheus)

## 🎯 Prochaines Étapes

1. ✅ Corriger `PROMETHEUS_TARGETS` avec l'URL HTTPS publique
2. ✅ Vérifier que le fichier de configuration est dans le volume (si utilisé)
3. ✅ Redémarrer Prometheus
4. ✅ Vérifier que le target beelzebub est UP
5. ⏭️ Configurer Loki pour les logs
6. ⏭️ Configurer Grafana avec les datasources

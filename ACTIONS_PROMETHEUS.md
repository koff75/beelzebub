# ✅ Actions Prometheus - Résumé

## 🎉 Corrections Effectuées

✅ **Variable PROMETHEUS_TARGETS corrigée :**
- ❌ Avant : `beelzebub:8080` (incorrect)
- ✅ Maintenant : `https://3il-ingenieurs.site/metrics` (correct)

## 📊 Configuration Actuelle

### Variables Configurées ✅

- ✅ `PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml`
- ✅ `PROMETHEUS_TARGETS=https://3il-ingenieurs.site/metrics`
- ✅ `SCRAPE_INTERVAL=15s`

### Observation Importante ⚠️

D'après les logs Prometheus, le fichier chargé est :
- `/etc/prometheus/prom.yml` (dans les logs)
- Mais la variable pointe vers : `/prometheus/prometheus.yml`

**Cela signifie que :**
- Soit Prometheus utilise un fichier de configuration par défaut (`/etc/prometheus/prom.yml`)
- Soit le fichier doit être ajouté au volume avec le bon nom

## 🔍 Vérifications à Faire

### 1. Vérifier si Prometheus utilise le fichier de configuration

**Option A : Prometheus utilise les variables d'environnement**
- Si `PROMETHEUS_TARGETS` est utilisé directement, c'est bon ✅
- Redémarrez Prometheus pour appliquer les changements

**Option B : Prometheus utilise un fichier de configuration**
- Le fichier doit être dans le volume à `/prometheus/prometheus.yml`
- OU à `/etc/prometheus/prom.yml` (selon la configuration)

### 2. Redémarrer Prometheus

Pour appliquer les changements :

```bash
# Via Railway Dashboard
# Prometheus > Settings > Restart

# Ou attendez le redéploiement automatique
```

### 3. Vérifier les Targets

1. **Accédez à Prometheus :**
   - URL : `https://prometheus-production.up.railway.app`
   - Ou via le domaine Railway du service Prometheus

2. **Vérifiez les targets :**
   - Allez dans **Status** > **Targets**
   - Le target `beelzebub` doit être `UP` (vert)
   - URL : `https://3il-ingenieurs.site/metrics`

3. **Testez une requête :**
   - Allez dans **Graph**
   - Testez : `beelzebub_events_total`
   - Vous devriez voir une valeur

## 🎯 Prochaines Étapes

### Si Prometheus scrape déjà beelzebub ✅

1. ✅ Prometheus configuré
2. ⏭️ **Configurer Loki** pour collecter les logs
3. ⏭️ **Configurer Grafana** avec les datasources
4. ⏭️ **Importer les dashboards**

### Si Prometheus ne scrape pas beelzebub ❌

1. **Vérifiez les logs :**
   ```bash
   railway logs --service Prometheus --lines 100
   ```
   - Cherchez les erreurs de scraping
   - Vérifiez les messages de configuration

2. **Vérifiez la connectivité :**
   - Testez manuellement : `curl https://3il-ingenieurs.site/metrics`
   - Vérifiez que beelzebub expose bien `/metrics`

3. **Vérifiez le fichier de configuration :**
   - Si Prometheus utilise un fichier, assurez-vous qu'il existe dans le volume
   - Le fichier `railway-prometheus-config.yml` doit être monté

## 📝 Checklist

- [x] Variable `PROMETHEUS_TARGETS` corrigée
- [ ] Prometheus redémarré (si nécessaire)
- [ ] Target `beelzebub` vérifié dans Prometheus UI
- [ ] Requête `beelzebub_events_total` testée
- [ ] Logs vérifiés pour les erreurs

## 🐛 Dépannage

### Le target est DOWN

1. Vérifiez que beelzebub expose `/metrics` : `https://3il-ingenieurs.site/metrics`
2. Vérifiez les logs Prometheus : `railway logs --service Prometheus`
3. Vérifiez la connectivité réseau entre Prometheus et beelzebub

### Prometheus ne charge pas la configuration

1. Vérifiez que le fichier existe dans le volume (si utilisé)
2. Vérifiez la syntaxe YAML du fichier de configuration
3. Vérifiez les logs pour les erreurs de parsing

### Les métriques ne s'affichent pas

1. Vérifiez que beelzebub génère des métriques
2. Vérifiez que Prometheus scrape bien beelzebub (targets UP)
3. Testez une requête simple : `beelzebub_events_total`

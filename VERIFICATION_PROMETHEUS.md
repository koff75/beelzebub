# ✅ Vérification Prometheus - État Actuel

## 📊 Configuration Vérifiée via Railway CLI

### ✅ Projet et Environnement
- **Project** : `zoological-dedication`
- **Environment** : `production`
- **Service** : `Prometheus`

### ✅ Variables Configurées

| Variable | Valeur | Status |
|----------|--------|--------|
| `PROMETHEUS_CONFIG_PATH` | `/prometheus/prometheus.yml` | ✅ |
| `PROMETHEUS_TARGETS` | `https://3il-ingenieurs.site/metrics` | ✅ Corrigé |
| `SCRAPE_INTERVAL` | `15s` | ✅ |
| `PORT` | `9090` | ✅ |
| `RAILWAY_SERVICE_BEELZEBUB_URL` | `3il-ingenieurs.site` | ✅ |

### ✅ État du Service

**Logs Prometheus :**
- ✅ Service démarré avec succès
- ✅ Configuration chargée : `/etc/prometheus/prom.yml`
- ✅ TSDB démarré
- ✅ Serveur prêt à recevoir des requêtes
- ✅ Port d'écoute : `9090`

**Observations :**
- Prometheus charge le fichier `/etc/prometheus/prom.yml` (pas `/prometheus/prometheus.yml`)
- Le volume est monté à `/prometheus`
- Le service fonctionne correctement

## 🔍 Points à Vérifier

### 1. Fichier de Configuration

**Situation actuelle :**
- Variable `PROMETHEUS_CONFIG_PATH` pointe vers `/prometheus/prometheus.yml`
- Mais Prometheus charge `/etc/prometheus/prom.yml` (d'après les logs)

**Actions possibles :**
- **Option A** : Le fichier `/etc/prometheus/prom.yml` est la configuration par défaut et utilise les variables d'environnement
- **Option B** : Le fichier doit être copié dans le volume à `/prometheus/prometheus.yml` ET renommé/symlink vers `/etc/prometheus/prom.yml`

### 2. Target beelzebub

**À vérifier dans Prometheus UI :**
1. Accédez à : `https://prometheus-production.up.railway.app` (ou le domaine Railway de Prometheus)
2. Allez dans **Status** > **Targets**
3. Vérifiez que le target `beelzebub` est :
   - ✅ **UP** (vert) = Tout fonctionne
   - ⚠️ **DOWN** (rouge) = Problème de connectivité ou configuration

### 3. Métriques beelzebub

**Test dans Prometheus :**
1. Allez dans **Graph**
2. Testez la requête : `beelzebub_events_total`
3. Si des données s'affichent = ✅ Configuration OK

## ✅ Checklist de Vérification

- [x] Projet lié : `zoological-dedication`
- [x] Environnement : `production`
- [x] Service : `Prometheus`
- [x] Variables configurées correctement
- [x] Service Prometheus démarré
- [ ] Target `beelzebub` vérifié dans Prometheus UI (UP/DOWN)
- [ ] Métriques `beelzebub_events_total` testées
- [ ] Logs vérifiés pour erreurs de scraping

## 🎯 Prochaines Actions

### Si le target est UP ✅

1. ✅ Prometheus est configuré et fonctionne
2. ⏭️ **Configurer Loki** pour collecter les logs
3. ⏭️ **Configurer Grafana** avec les datasources
4. ⏭️ **Importer les dashboards**

### Si le target est DOWN ❌

1. **Vérifier la connectivité :**
   ```bash
   # Tester depuis Prometheus vers beelzebub
   curl https://3il-ingenieurs.site/metrics
   ```

2. **Vérifier les logs Prometheus :**
   ```bash
   railway logs --service Prometheus --lines 100
   ```
   - Cherchez les erreurs de scraping
   - Vérifiez les messages de connexion

3. **Vérifier la configuration :**
   - Si Prometheus utilise un fichier, vérifiez qu'il contient bien le target beelzebub
   - Si Prometheus utilise les variables, vérifiez que `PROMETHEUS_TARGETS` est correct

## 📝 Commandes Utiles

```bash
# Vérifier les variables
railway variables --service Prometheus

# Voir les logs
railway logs --service Prometheus --lines 50

# Vérifier le statut
railway status

# Tester l'endpoint beelzebub
curl https://3il-ingenieurs.site/metrics
```

## 🎉 Résumé

**Configuration actuelle :**
- ✅ Variables correctement configurées
- ✅ Service Prometheus fonctionnel
- ✅ Target configuré : `https://3il-ingenieurs.site/metrics`

**À faire :**
- Vérifier dans Prometheus UI que le target `beelzebub` est UP
- Tester les métriques : `beelzebub_events_total`

**Si tout est OK :**
- Passer à la configuration de Loki et Grafana

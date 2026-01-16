# ✅ Configuration Prometheus - Étape Finale

## 🎉 Ce qui a été fait

✅ Variable `PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml` ajoutée au service Prometheus

## 📋 Étape finale : Ajouter le fichier de configuration au volume

Le fichier `railway-prometheus-config.yml` doit être copié dans le volume Prometheus à `/prometheus/prometheus.yml`.

### Option 1 : Via l'interface Railway (Recommandé)

1. **Allez dans Railway Dashboard :**
   - Projet : `zoological-dedication`
   - Service : **Prometheus**
   - Onglet : **Settings** > **Volumes**

2. **Ajoutez le fichier au volume :**
   - Le volume `prometheus-volume` est monté à `/prometheus`
   - Vous devez ajouter le fichier `railway-prometheus-config.yml` au volume
   - Le fichier doit être nommé `prometheus.yml` dans le volume
   - Chemin final : `/prometheus/prometheus.yml`

3. **Méthode :**
   - Si Railway permet d'uploader des fichiers dans le volume, utilisez cette fonctionnalité
   - Sinon, modifiez le Dockerfile (voir Option 2)

### Option 2 : Modifier le Dockerfile

Si vous avez accès au Dockerfile de Prometheus (`/prometheus/dockerfile`) :

1. **Ajoutez cette ligne au Dockerfile :**
   ```dockerfile
   COPY railway-prometheus-config.yml /prometheus/prometheus.yml
   ```

2. **Ou si le fichier est dans le repo :**
   ```dockerfile
   COPY prometheus-config/prometheus.yml /prometheus/prometheus.yml
   ```

3. **Redéployez le service**

### Option 3 : Via Railway CLI (si disponible)

```bash
# Si Railway CLI supporte l'upload de fichiers dans les volumes
railway volume upload prometheus-volume railway-prometheus-config.yml /prometheus/prometheus.yml
```

## ✅ Vérification

Une fois le fichier ajouté au volume :

1. **Redémarrez le service Prometheus** (si nécessaire)
   - Railway Dashboard > Prometheus > Settings > Restart

2. **Vérifiez les logs :**
   ```bash
   railway logs --service prometheus
   ```
   - Vous devriez voir que Prometheus charge la configuration

3. **Vérifiez les targets dans Prometheus :**
   - Accédez à Prometheus : `https://prometheus-production.up.railway.app`
   - Allez dans **Status** > **Targets**
   - Le target `beelzebub` doit être `UP` (vert)
   - URL : `https://3il-ingenieurs.site/metrics`

4. **Testez une requête :**
   - Allez dans **Graph**
   - Testez : `beelzebub_events_total`
   - Vous devriez voir une valeur

## 📝 Résumé de la configuration

**Variables configurées :**
- ✅ `PROMETHEUS_CONFIG_PATH=/prometheus/prometheus.yml`

**Fichier de configuration :**
- 📄 `railway-prometheus-config.yml` (à copier dans le volume)

**Configuration dans le fichier :**
- Target : `https://3il-ingenieurs.site/metrics`
- Job name : `beelzebub`
- Scrape interval : `15s`
- Scheme : `https`

## 🐛 Dépannage

### Prometheus ne charge pas la configuration

1. Vérifiez que le fichier existe : `/prometheus/prometheus.yml`
2. Vérifiez les logs : `railway logs --service prometheus`
3. Vérifiez la syntaxe YAML du fichier de configuration

### Le target beelzebub est DOWN

1. Vérifiez que beelzebub expose `/metrics` : `https://3il-ingenieurs.site/metrics`
2. Vérifiez la connectivité réseau
3. Vérifiez les logs Prometheus pour les erreurs de scraping

### Le fichier n'est pas dans le volume

1. Vérifiez que le volume est bien monté
2. Utilisez l'interface Railway pour ajouter le fichier
3. Ou modifiez le Dockerfile pour inclure le fichier

## 🎯 Prochaines étapes

Une fois Prometheus configuré :

1. ✅ Prometheus scrape beelzebub
2. ⏭️ Configurer Loki pour collecter les logs
3. ⏭️ Configurer Grafana avec les datasources
4. ⏭️ Importer les dashboards

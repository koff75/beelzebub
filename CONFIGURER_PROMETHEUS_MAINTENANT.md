# Configuration Prometheus via Railway CLI - Guide Rapide

## 🎯 Objectif

Configurer Prometheus pour scraper les métriques de beelzebub via Railway CLI.

## 📋 Étapes

### Étape 1 : Lier le projet (si pas déjà fait)

```bash
railway link --project zoological-dedication
```

Sélectionnez :
- Workspace : `NicoProjects`
- Project : `zoological-dedication`
- Environment : `production`

### Étape 2 : Lier le service Prometheus

```bash
railway service
```

Sélectionnez `Prometheus` dans le menu.

### Étape 3 : Vérifier les variables actuelles

```bash
railway variables
```

### Étape 4 : Configurer Prometheus

**Option A : Si Prometheus accepte des variables d'environnement pour les targets**

```bash
# Ajouter le target beelzebub
railway variables --set "PROMETHEUS_TARGETS=beelzebub:https://3il-ingenieurs.site/metrics"

# Configurer l'intervalle de scrape
railway variables --set "SCRAPE_INTERVAL=15s"
```

**Option B : Si Prometheus nécessite un fichier de configuration**

1. **Créer un volume dans Railway :**
   - Allez dans Railway Dashboard > Prometheus > Settings > Volumes
   - Créez un volume (ex: `prometheus-config`)
   - Montez-le à `/etc/prometheus`

2. **Ajouter le fichier de configuration :**
   - Le fichier `railway-prometheus-config.yml` doit être monté dans le volume
   - Configurez la variable :
   ```bash
   railway variables --set "PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml"
   ```

**Option C : Configuration via l'interface Railway (Recommandé si les options A et B ne fonctionnent pas)**

1. Allez sur [Railway Dashboard](https://railway.app)
2. Sélectionnez le projet `zoological-dedication`
3. Cliquez sur le service **Prometheus**
4. Allez dans **Settings** ou **Variables**
5. Si Prometheus a une interface de configuration :
   - Ajoutez un nouveau scrape target :
     - **Job name** : `beelzebub`
     - **Target URL** : `https://3il-ingenieurs.site/metrics`
     - **Scheme** : `https`
     - **Scrape interval** : `15s`

## ✅ Vérification

### Vérifier que Prometheus scrape beelzebub

1. **Accédez à Prometheus :**
   - URL : Généralement `https://prometheus-production.up.railway.app`
   - Ou via le domaine Railway du service Prometheus

2. **Vérifiez les targets :**
   - Allez dans **Status** > **Targets**
   - Le target `beelzebub` doit être `UP` (vert)

3. **Testez une requête :**
   - Allez dans **Graph**
   - Testez : `beelzebub_events_total`
   - Vous devriez voir une valeur

## 🔧 Commandes complètes

Voici la séquence complète de commandes :

```bash
# 1. Lier le projet
railway link --project zoological-dedication

# 2. Lier le service Prometheus (sélectionnez Prometheus dans le menu)
railway service

# 3. Voir les variables actuelles
railway variables

# 4. Configurer les variables (selon votre configuration Prometheus)
# Option 1 : Variables simples
railway variables --set "PROMETHEUS_TARGETS=beelzebub:https://3il-ingenieurs.site/metrics"
railway variables --set "SCRAPE_INTERVAL=15s"

# Option 2 : Chemin de configuration
railway variables --set "PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml"
```

## 📝 Note importante

La configuration exacte dépend de **comment Prometheus est déployé sur Railway** :

- **Template Railway** : Peut avoir des variables spécifiques
- **Image Docker standard** : Nécessite un fichier de configuration monté
- **Configuration personnalisée** : Peut accepter des variables d'environnement

Si les commandes ci-dessus ne fonctionnent pas, utilisez l'**Option C** (interface web Railway) qui fonctionne dans tous les cas.

## 🐛 Dépannage

### Le service Prometheus n'est pas trouvé

```bash
# Vérifiez que le projet est lié
railway status

# Reliez le projet si nécessaire
railway link --project zoological-dedication
```

### Les variables ne sont pas appliquées

1. Vérifiez que le service Prometheus est bien lié
2. Vérifiez les logs : `railway logs --service prometheus`
3. Redémarrez le service si nécessaire

### Prometheus ne scrape pas beelzebub

1. Vérifiez que beelzebub expose `/metrics` : `https://3il-ingenieurs.site/metrics`
2. Vérifiez la configuration dans Prometheus UI
3. Vérifiez les logs Prometheus

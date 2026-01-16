# Configuration de l'Architecture Existante Railway

Guide spécifique pour configurer votre architecture déjà déployée sur Railway.

## 🏗️ Architecture Actuelle

```
┌─────────────┐
│  beelzebub  │─── Métriques ───> Prometheus ───┐
│  (Honeypot) │─── Logs ───────> Loki ─────────┤
│             │─── Traces ──────> Tempo ────────┤
└─────────────┘                                 │
                                                ▼
                                          ┌──────────┐
                                          │ Grafana  │
                                          │(Dashboard)│
                                          └──────────┘
```

**Services déployés :**
- ✅ beelzebub (3il-ingenieurs.site)
- ✅ Prometheus
- ✅ Loki
- ✅ Tempo
- ✅ Grafana

## 🎯 Objectif

Connecter tous les services et importer les dashboards Grafana pour visualiser les KPIs du honeypot.

## 📊 Étape 1 : Configurer Prometheus pour scraper beelzebub

### 1.1 Vérifier l'accès aux métriques

1. **Testez l'endpoint métriques :**
   ```
   https://3il-ingenieurs.site/metrics
   ```
   Vous devriez voir les métriques Prometheus (beelzebub_events_total, etc.)

### 1.2 Configurer Prometheus

**Option A : Via l'interface Railway (Recommandé)**

1. Allez sur [Railway Dashboard](https://railway.app)
2. Sélectionnez le projet `zoological-dedication`
3. Cliquez sur le service **Prometheus**
4. Allez dans l'onglet **Variables** ou **Settings**

5. **Si Prometheus utilise un fichier de configuration :**
   - Montez le fichier `railway-prometheus-config.yml` dans un volume
   - OU ajoutez la configuration via variables d'environnement

6. **Si Prometheus a une interface de configuration :**
   - Ajoutez un nouveau scrape target :
     - **Job name** : `beelzebub`
     - **Target URL** : `https://3il-ingenieurs.site/metrics`
     - **Scheme** : `https`
     - **Scrape interval** : `15s`

**Option B : Via Railway CLI**

```bash
# Lier le service Prometheus
railway service prometheus

# Vérifier les variables existantes
railway variables

# Si Prometheus accepte la config via variables, ajoutez :
railway variables --set "PROMETHEUS_TARGETS=beelzebub:https://3il-ingenieurs.site/metrics"
```

### 1.3 Vérifier la configuration

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

## 📝 Étape 2 : Configurer Loki pour collecter les logs

### 2.1 Vérifier la collecte de logs

Les logs Railway sont automatiquement disponibles. Il faut configurer Loki pour les parser.

### 2.2 Configurer Promtail (si nécessaire)

**Si Promtail n'est pas déjà déployé :**

1. **Créer un service Promtail :**
   - Dans Railway, cliquez sur **+ New** > **Empty Service**
   - Nommez-le `promtail`
   - Utilisez l'image : `grafana/promtail:latest`

2. **Configurer Promtail :**
   - Montez le fichier `loki-config/promtail-config.yaml`
   - Ajoutez les variables :
     ```
     LOKI_URL=http://loki:3100
     ```

**Si les logs sont déjà collectés :**

1. Vérifiez que Loki reçoit les logs
2. Testez une requête LogQL dans Grafana

### 2.3 Configuration alternative : Collecte directe depuis Railway

Railway expose les logs via son API. Si Loki est configuré pour les recevoir directement :

1. Vérifiez la configuration Loki
2. Les logs beelzebub devraient être automatiquement disponibles

### 2.4 Vérifier la configuration

1. **Accédez à Loki :**
   - URL : Généralement `https://loki-production.up.railway.app`
   - Ou via le domaine Railway du service Loki

2. **Testez une requête LogQL :**
   ```logql
   {service="beelzebub"} |= "HTTP New request"
   ```

## 📈 Étape 3 : Configurer Grafana

### 3.1 Accéder à Grafana

1. **Trouvez l'URL Grafana :**
   - Dans Railway, cliquez sur le service **Grafana**
   - Notez l'URL publique (ex: `https://grafana-production.up.railway.app`)
   - Ou générez un domaine : **Settings** > **Generate Domain**

2. **Connectez-vous :**
   - URL : Votre URL Grafana
   - Identifiants par défaut : `admin` / `admin`
   - **⚠️ Changez le mot de passe à la première connexion !**

### 3.2 Ajouter les datasources

#### Datasource Prometheus

1. Allez dans **Configuration** (icône ⚙️) > **Data sources**
2. Cliquez sur **Add data source**
3. Sélectionnez **Prometheus**
4. Configurez :
   - **Name** : `Prometheus` (ou gardez le nom par défaut)
   - **URL** : 
     - **Interne** : `http://prometheus:9090` (si les services communiquent en interne)
     - **Externe** : `https://prometheus-production.up.railway.app` (URL publique)
   - **Access** : `Server (default)` (recommandé)
   - **UID** : `prometheus` ⚠️ **IMPORTANT pour les dashboards**
5. Cliquez sur **Save & Test**
6. Vous devriez voir : ✅ "Data source is working"

#### Datasource Loki

1. Cliquez sur **Add data source**
2. Sélectionnez **Loki**
3. Configurez :
   - **Name** : `Loki` (ou gardez le nom par défaut)
   - **URL** :
     - **Interne** : `http://loki:3100` (si les services communiquent en interne)
     - **Externe** : `https://loki-production.up.railway.app` (URL publique)
   - **Access** : `Server (default)` (recommandé)
   - **UID** : `loki` ⚠️ **IMPORTANT pour les dashboards**
4. Cliquez sur **Save & Test**
5. Vous devriez voir : ✅ "Data source is working"

#### Datasource Tempo (Optionnel)

1. Cliquez sur **Add data source**
2. Sélectionnez **Tempo**
3. Configurez :
   - **URL** : `http://tempo:3200` (interne) ou URL publique Tempo
   - **UID** : `tempo`
4. Cliquez sur **Save & Test**

### 3.3 Importer les dashboards

#### Dashboard 1 : Beelzebub Overview

1. Allez dans **Dashboards** (icône 📊) > **Import**
2. Cliquez sur **Upload JSON file**
3. Sélectionnez le fichier : `grafana-dashboards/beelzebub-overview.json`
   - Ou copiez-collez le contenu JSON
4. Vérifiez que les datasources sont correctement sélectionnés :
   - Prometheus : `Prometheus` (ou le nom que vous avez donné)
   - Loki : `Loki` (ou le nom que vous avez donné)
5. Cliquez sur **Import**
6. Le dashboard s'ouvre automatiquement

#### Dashboard 2 : Exploit Detection

1. Répétez les étapes pour `grafana-dashboards/beelzebub-exploit-detection.json`
2. Ce dashboard se concentre sur la détection CVE-2026-21858

#### Dashboard 3 : IP Analysis

1. Répétez les étapes pour `grafana-dashboards/beelzebub-ip-analysis.json`
2. Ce dashboard analyse le comportement des IPs sources

### 3.4 Vérifier les dashboards

1. **Ouvrez chaque dashboard**
2. **Vérifiez que les panels affichent des données :**
   - Si des panels sont vides, vérifiez :
     - Les datasources (UIDs doivent être `prometheus` et `loki`)
     - Les données sont disponibles (testez dans **Explore**)
     - Les requêtes sont correctes

3. **Testez dans Explore :**
   - **Prometheus** : `beelzebub_events_total`
   - **Loki** : `{service="beelzebub"} |= "HTTP New request"`

## 🔍 Étape 4 : Vérification complète

### Checklist

- [ ] Prometheus scrape les métriques de beelzebub
  - [ ] Target `beelzebub` est `UP` dans Prometheus
  - [ ] Requête `beelzebub_events_total` retourne des données

- [ ] Loki collecte les logs
  - [ ] Requête `{service="beelzebub"}` retourne des logs
  - [ ] Les logs sont structurés en JSON

- [ ] Grafana est configuré
  - [ ] Datasource Prometheus configuré (UID: `prometheus`)
  - [ ] Datasource Loki configuré (UID: `loki`)
  - [ ] Les 3 dashboards sont importés

- [ ] Les dashboards fonctionnent
  - [ ] Dashboard Overview affiche des métriques
  - [ ] Dashboard Exploit Detection fonctionne
  - [ ] Dashboard IP Analysis affiche des données

## 🐛 Dépannage

### Prometheus ne scrape pas beelzebub

**Symptômes :**
- Target `beelzebub` est `DOWN` dans Prometheus
- Requête `beelzebub_events_total` ne retourne rien

**Solutions :**
1. Vérifiez que beelzebub expose `/metrics` :
   ```
   https://3il-ingenieurs.site/metrics
   ```
2. Vérifiez la configuration du target dans Prometheus
3. Vérifiez les logs Prometheus : `railway logs --service prometheus`
4. Essayez l'URL publique au lieu de l'URL interne

### Loki ne collecte pas les logs

**Symptômes :**
- Requête `{service="beelzebub"}` ne retourne rien
- Les logs ne sont pas structurés

**Solutions :**
1. Vérifiez que Promtail est déployé et fonctionne
2. Vérifiez la connectivité entre Promtail et Loki
3. Vérifiez les logs Loki : `railway logs --service loki`
4. Vérifiez le format des logs (doivent être JSON)

### Les dashboards sont vides

**Symptômes :**
- Les panels affichent "No data"
- Les requêtes ne retournent rien

**Solutions :**
1. **Vérifiez les datasources :**
   - Les UIDs doivent être exactement `prometheus` et `loki`
   - Testez les datasources dans **Explore**

2. **Vérifiez les requêtes :**
   - Testez directement dans **Explore**
   - Vérifiez que les données sont disponibles

3. **Vérifiez les labels :**
   - Les requêtes utilisent `{service="beelzebub"}`
   - Vérifiez que ce label existe dans vos logs

4. **Modifiez les dashboards :**
   - Si les UIDs ne correspondent pas, modifiez les dashboards
   - Ou recréez les datasources avec les bons UIDs

## 📚 Commandes utiles

```bash
# Voir les services
railway service

# Voir les logs
railway logs --service beelzebub
railway logs --service prometheus
railway logs --service loki
railway logs --service grafana

# Voir les variables
railway variables

# Lier un service spécifique
railway service prometheus
railway service loki
railway service grafana
```

## 🎉 Résultat attendu

Une fois configuré, vous devriez avoir :

1. **Prometheus** qui scrape les métriques de beelzebub en temps réel
2. **Loki** qui collecte et indexe les logs structurés
3. **Grafana** avec 3 dashboards fonctionnels :
   - **Overview** : Vue d'ensemble avec métriques et logs corrélés
   - **Exploit Detection** : Détection en temps réel des tentatives CVE-2026-21858
   - **IP Analysis** : Analyse comportementale des IPs sources

## 🔗 URLs des services

Sur Railway, chaque service a généralement une URL du type :
- `https://beelzebub-production.up.railway.app` → `3il-ingenieurs.site`
- `https://prometheus-production.up.railway.app`
- `https://loki-production.up.railway.app`
- `https://tempo-production.up.railway.app`
- `https://grafana-production.up.railway.app`

Pour la communication interne entre services, utilisez les noms de service :
- `http://prometheus:9090`
- `http://loki:3100`
- `http://tempo:3200`
- `http://grafana:3000`

## 📝 Notes importantes

1. **UIDs des datasources** : Les dashboards utilisent les UIDs `prometheus` et `loki`. Assurez-vous que vos datasources ont exactement ces UIDs.

2. **Format des logs** : Les logs Beelzebub sont au format JSON structuré. Assurez-vous que Loki/Promtail peut les parser.

3. **Sécurité** : Changez les mots de passe par défaut de Grafana et sécurisez l'accès aux services.

4. **Performance** : Ajustez les intervalles de scrape selon vos besoins et la charge.

## 🚀 Prochaines étapes

Une fois la configuration terminée :

1. ✅ Surveillez les métriques en temps réel
2. ✅ Analysez les logs structurés
3. ✅ Détectez les tentatives d'exploitation
4. ✅ Analysez le comportement des attaquants
5. ⚠️ Configurez les alertes (optionnel)
6. ⚠️ Optimisez les performances (optionnel)

# 🚀 Étapes Finales - Éjection des Services Railway

## ✅ Ce qui a été fait

Toutes les modifications ont été poussées sur le fork : **https://github.com/koff75/railway-grafana-stack**

### Modifications dans le fork

1. ✅ **Prometheus** : Target beelzebub ajouté dans `prometheus/prom.yml`
2. ✅ **Grafana** : Datasources avec UIDs corrects (prometheus, loki, tempo)
3. ✅ **Grafana** : 3 dashboards Beelzebub ajoutés avec provisioning automatique
4. ✅ **Loki** : Configuration Promtail créée (pour référence future)

## 🔧 Étape Finale : Éjecter les Services Railway

### Pour chaque service (Prometheus, Loki, Tempo, Grafana)

#### Instructions détaillées

1. **Allez sur [Railway Dashboard](https://railway.app)**
2. **Sélectionnez le projet** `zoological-dedication`
3. **Pour chaque service, suivez ces étapes :**

### Prometheus

1. Cliquez sur le service **Prometheus**
2. Allez dans **Settings**
3. Cherchez la section **Source** ou **Repository**
4. **Si "Eject" ou "Transform to Code" est disponible :**
   - Cliquez dessus
   - Sélectionnez votre fork : `koff75/railway-grafana-stack`
   - Sélectionnez le dossier : `prometheus/`

5. **Sinon (Disconnect/Reconnect) :**
   - Cliquez sur **Disconnect** (déconnecte du template)
   - Cliquez sur **Connect** ou **New Service** > **GitHub Repo**
   - Sélectionnez : `koff75/railway-grafana-stack`
   - **Root Directory** : `prometheus/`
   - Cliquez sur **Deploy**

### Grafana

1. Cliquez sur le service **Grafana**
2. Allez dans **Settings**
3. **Disconnect** puis **Connect** au fork
4. Sélectionnez : `koff75/railway-grafana-stack`
5. **Root Directory** : `grafana/`
6. Cliquez sur **Deploy**

### Loki

1. Cliquez sur le service **Loki**
2. Allez dans **Settings**
3. **Disconnect** puis **Connect** au fork
4. Sélectionnez : `koff75/railway-grafana-stack`
5. **Root Directory** : `loki/`
6. Cliquez sur **Deploy**

### Tempo

1. Cliquez sur le service **Tempo**
2. Allez dans **Settings**
3. **Disconnect** puis **Connect** au fork
4. Sélectionnez : `koff75/railway-grafana-stack`
5. **Root Directory** : `tempo/`
6. Cliquez sur **Deploy**

## ⚠️ Points Importants

1. **Root Directory** : Assurez-vous de sélectionner le bon dossier pour chaque service
2. **Variables d'environnement** : Elles seront conservées automatiquement
3. **Volumes** : Les volumes existants seront conservés
4. **Redéploiement** : Railway redéploiera automatiquement après la connexion

## ✅ Vérification après Éjection

### Prometheus

1. Attendez que le service redéploie (2-3 minutes)
2. Accédez à Prometheus UI : `https://prometheus-production-5ee3.up.railway.app`
3. Allez dans **Status** > **Targets**
4. Vérifiez que le target `beelzebub` est **UP** (vert)
5. Testez : `beelzebub_events_total` dans Graph

### Grafana

1. Attendez que le service redéploie
2. Accédez à Grafana : `https://grafana-production-8143.up.railway.app`
3. Connectez-vous (koff75 / mot de passe dans variables)
4. **Vérifiez les datasources :**
   - Configuration > Data sources
   - Prometheus, Loki, Tempo doivent être configurés
   - UIDs : `prometheus`, `loki`, `tempo`

5. **Vérifiez les dashboards :**
   - Dashboards > Dossier "Beelzebub"
   - Les 3 dashboards doivent être visibles et fonctionnels

## 🎉 Résultat Final

Une fois tous les services éjectés et connectés au fork :

- ✅ **Prometheus** scrape automatiquement beelzebub
- ✅ **Grafana** a les datasources configurés automatiquement
- ✅ **Grafana** a les 3 dashboards importés automatiquement
- ✅ Toute la configuration est versionnée dans Git
- ✅ Les modifications futures se font dans le code, pas dans l'UI

## 📝 Commandes Utiles

```bash
# Voir les logs d'un service
railway logs --service Prometheus
railway logs --service Grafana

# Vérifier les variables
railway variables --service Prometheus
railway variables --service Grafana
```

## 🔗 Liens Utiles

- Fork GitHub : https://github.com/koff75/railway-grafana-stack
- Railway Dashboard : https://railway.app
- Guide d'éjection : `GUIDE_EJECTION_RAILWAY.md` (dans le fork)

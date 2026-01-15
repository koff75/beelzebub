# Guide des Statistiques du Honeypot Beelzebub

## 📊 Méthodes pour voir les statistiques

### 1. Métriques Prometheus (Recommandé)

Beelzebub expose des métriques Prometheus sur le port **2112** à l'endpoint `/metrics`.

**Métriques disponibles :**
- `beelzebub_events_total` - Nombre total d'événements capturés
- `beelzebub_http_events_total` - Nombre d'événements HTTP
- `beelzebub_ssh_events_total` - Nombre d'événements SSH
- `beelzebub_tcp_events_total` - Nombre d'événements TCP
- `beelzebub_mcp_events_total` - Nombre d'événements MCP

**Problème sur Railway :** Le port 2112 n'est pas exposé publiquement par défaut.

**Solutions :**

#### Option A : Exposer les métriques via un endpoint HTTP (Recommandé)
Ajouter un endpoint `/metrics` sur le même port que le service HTTP (8080).

#### Option B : Utiliser Railway Metrics
Railway a un onglet "Metrics" qui peut afficher certaines métriques.

#### Option C : Tunnel Railway (pour accès local)
```bash
railway connect 2112
```

### 2. Logs Railway (Déjà disponible)

Les logs Railway contiennent tous les événements avec détails complets :

**Dans l'interface Railway :**
- Onglet **Logs** → Voir tous les événements en temps réel
- Filtrer par "New Event" pour voir les tentatives d'intrusion
- Chaque événement contient :
  - IP source
  - User-Agent
  - URI de la requête
  - Body (pour les POST)
  - Timestamp
  - Headers complets

**Via Railway CLI :**
```bash
railway logs
railway logs --filter "HTTP New request"
```

### 3. Fichiers de logs locaux (si déployé localement)

Si vous déployez localement, les logs sont dans `./logs` (configuré dans `beelzebub.yaml`).

## 🔧 Solution : Exposer les métriques Prometheus sur le port HTTP

Pour rendre les métriques accessibles publiquement, nous pouvons modifier le code pour exposer `/metrics` sur le même serveur HTTP.

**Avantages :**
- Accès direct via `https://beelzebub-production.up.railway.app/metrics`
- Compatible avec Grafana, Prometheus, etc.
- Pas besoin d'exposer un port supplémentaire

## 📈 Statistiques disponibles dans les logs

Chaque événement loggé contient :
- **DateTime** : Timestamp de l'événement
- **SourceIp** : IP source de l'attaquant
- **Protocol** : HTTP, SSH, TCP, MCP
- **HTTPMethod** : GET, POST, etc.
- **RequestURI** : Chemin de la requête
- **UserAgent** : Navigateur/outil utilisé
- **Body** : Contenu des requêtes POST
- **Headers** : Tous les en-têtes HTTP
- **Description** : Description du honeypot

## ✅ Solution implémentée : Endpoint `/metrics` sur le port HTTP

Un endpoint `/metrics` a été ajouté au serveur HTTP pour exposer les métriques Prometheus.

**Accès aux statistiques :**
```
https://beelzebub-production.up.railway.app/metrics
```

**Métriques disponibles :**
- `beelzebub_events_total` - Nombre total d'événements
- `beelzebub_http_events_total` - Nombre d'événements HTTP
- `beelzebub_ssh_events_total` - Nombre d'événements SSH
- `beelzebub_tcp_events_total` - Nombre d'événements TCP
- `beelzebub_mcp_events_total` - Nombre d'événements MCP

**Format :** Métriques au format Prometheus (OpenMetrics)

**Exemple de réponse :**
```
# HELP beelzebub_events_total The total number of events
# TYPE beelzebub_events_total counter
beelzebub_events_total 42

# HELP beelzebub_http_events_total The total number of HTTP events
# TYPE beelzebub_http_events_total counter
beelzebub_http_events_total 38
```

## 🔄 Déploiement

Après le commit et push, Railway redéploiera automatiquement et l'endpoint `/metrics` sera accessible.

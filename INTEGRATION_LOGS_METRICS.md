# Intégration Logs et Métriques – Flux dans le code source

Ce document décrit **où et comment** les logs et les métriques sont produits, et comment ils atteignent **Prometheus** et **Loki**.

---

## 1. Vue d’ensemble du flux

```
Requête HTTP (/, /rest/..., /form/..., etc.)
        │
        ▼
┌─────────────────────────────────────────────────────────────────┐
│  protocols/strategies/HTTP/http.go                               │
│  buildHTTPResponse() → traceRequest(request, tr, command, ...)    │
└─────────────────────────────────────────────────────────────────┘
        │
        ├──► tr.TraceEvent(event)  ──►  tracer (metrics + strategy)
        │
        └──► /metrics  :  pas de traceRequest, servie par promhttp.Handler()
```

- **Métriques (Prometheus)** : remontées dans le **tracer** et exposées via **`/metrics`** sur le serveur HTTP (même port que le honeypot, ex. 8080).
- **Logs** : émis par la **stratégie de trace** (ex. `standardOutStrategy`) après passage par le tracer. L’envoi vers **Loki** se fait dans cette stratégie si `LOKI_URL` est défini.

---

## 2. Métriques (Prometheus)

### 2.1 Où sont créées les métriques

**Fichier :** `tracer/tracer.go`

- **Compteurs (promauto.NewCounter) :**
  - `beelzebub_events_total`
  - `beelzebub_http_events_total`
  - `beelzebub_ssh_events_total`
  - `beelzebub_tcp_events_total`
  - `beelzebub_mcp_events_total`

- **Mise à jour :** dans `TraceEvent()` → `updatePrometheusCounters(event.Protocol)` :
  - incrémentation du compteur du protocole (http/ssh/tcp/mcp)
  - incrémentation de `beelzebub_events_total`

Les métriques sont enregistrées dans le **registre Prometheus par défaut** (`prometheus.DefaultRegisterer`).

### 2.2 Où est appelé TraceEvent

**Fichier :** `protocols/strategies/HTTP/http.go`

- `buildHTTPResponse()` appelle `traceRequest(request, tr, command, servConf.Description, body)`.
- `traceRequest()` construit un `tracer.Event` (Msg, SourceIp, RequestURI, HTTPMethod, UserAgent, etc.) puis appelle `tr.TraceEvent(event)`.

**Important :** les requêtes vers **`/metrics`** sont gérées par un `HandleFunc("/metrics", ...)` **avant** le `HandleFunc("/", ...)`. Elles ne passent pas par `buildHTTPResponse` ni `traceRequest`. Les scrapes Prometheus ne sont donc **pas** comptés comme événements honeypot.

### 2.3 Où est exposé `/metrics`

**Deux endroits (même registre Prometheus, donc mêmes métriques) :**

1. **Serveur HTTP du honeypot (celui qui sert 8080 / PORT)**  
   **Fichier :** `protocols/strategies/HTTP/http.go`  
   - `serverMux.HandleFunc("/metrics", func(...) { promhttp.Handler().ServeHTTP(...) })`  
   - C’est **ce** `/metrics` qui est scrapé par Prometheus sur `https://3il-ingenieurs.site/metrics` (ou l’URL publique du service).

2. **Serveur Prometheus dédié (optionnel)**  
   **Fichier :** `builder/builder.go`  
   - `http.Handle(core.Prometheus.Path, promhttp.Handler())` puis `http.ListenAndServe(core.Prometheus.Port, nil)` (ex. `:2112`).  
   - Config dans `beelzebub.yaml` : `prometheus.path: "/metrics"`, `prometheus.port: ":2112"`.  
   - Sur Railway, seul le port `PORT` (8080) est exposé, donc **en pratique c’est le 1** qui est utilisé.

### 2.4 Résumé Prometheus

| Élément | Fichier / lieu |
|--------|----------------|
| Création / incrémentation des compteurs | `tracer/tracer.go` : `TraceEvent` → `updatePrometheusCounters` |
| Déclenchement (événement HTTP) | `protocols/strategies/HTTP/http.go` : `traceRequest` → `tr.TraceEvent(event)` |
| Exposition | `protocols/strategies/HTTP/http.go` : `/metrics` → `promhttp.Handler()` |
| Scrape | Prometheus interroge `https://3il-ingenieurs.site/metrics` (ou équivalent) |

---

## 3. Logs (stdout et fichier)

### 3.1 Configuration du logger

**Fichier :** `builder/builder.go` → `buildLogger()`

- **Sorties :** `log.SetOutput(io.MultiWriter(os.Stdout, logsFile))`  
  → chaque log va à la fois sur **stdout** et dans le fichier `logsPath` (ex. `./logs`).
- **Format :** `log.SetFormatter(&log.JSONFormatter{...})`  
  → logs en **JSON** (level, msg, champs, etc.).
- **Niveau :** `Info` ou `Debug` selon la config (`beelzebub.yaml` → `core.logging.debug`).

### 3.2 Où sont produits les logs d’événements

**Fichier :** `builder/director.go`

La **stratégie de trace** choisie par le Director est celle qui logue. Selon la config :

- **`standardOutStrategy`** (par défaut si RabbitMQ et BeelzebubCloud désactivés) :
  ```go
  log.WithFields(log.Fields{
      "status": event.Status,
      "event":  event,
  }).Info("New Event")
  ```
  → une ligne JSON avec `"msg":"New Event"` et les champs `status`, `event` (objet complet).

- **`rabbitMQTraceStrategy`** et **`beelzebubCloudStrategy`** font aussi un `log.Info("New Event")` avec les mêmes `log.Fields`, mais **n’appellent pas** `pushToLoki`. L’envoi vers Loki ne se fait que dans `standardOutStrategy`.

### 3.3 Chemin des événements jusqu’au log

1. `traceRequest` (HTTP) → `tr.TraceEvent(event)`
2. `tracer.TraceEvent` :  
   - `event.DateTime = time.Now().UTC().Format(time.RFC3339)`  
   - envoi de `event` dans `eventsChan`  
   - `updatePrometheusCounters(event.Protocol)`
3. Un **worker** du tracer lit `eventsChan` et appelle `strategy(event)` (ex. `standardOutStrategy`).
4. `standardOutStrategy` fait `log.WithFields(...).Info("New Event")`  
   → sortie **stdout + fichier** via `log.SetOutput(io.MultiWriter(...))`.

### 3.4 Format des logs stdout/fichier

Exemple (structure logrus JSON) :

```json
{
  "level": "info",
  "msg": "New Event",
  "status": "Stateless",
  "event": {
    "DateTime": "2026-01-17T21:00:00Z",
    "Msg": "HTTP New request",
    "SourceIp": "193.19.82.13",
    "RequestURI": "/",
    "HTTPMethod": "GET",
    "UserAgent": "Mozilla/5.0...",
    "Handler": "n8n Homepage SEO",
    "Body": "",
    "Headers": "[Key: User-Agent, values: ...],",
    "Description": "n8n workflow automation platform - CVE-2026-21858 honeypot",
    "ID": "de090320-2b3b-440a-a75d-4d0750d55350",
    ...
  }
}
```

- `event.Msg` = `"HTTP New request"` (ou `"HTTPS New Request"` si TLS).
- Ces logs **ne partent pas automatiquement** vers Loki : ils sont seulement sur stdout (et dans `./logs` en local). Sur Railway, stdout est visible dans les Deploy Logs, mais aucun agent ne les pousse vers Loki par défaut.

---

## 4. Intégration Loki (push direct depuis Beelzebub)

### 4.1 Où c’est implémenté

**Fichier :** `builder/director.go`

- **Condition :** `if lokiURL := os.Getenv("LOKI_URL"); lokiURL != "" { go pushToLoki(lokiURL, event) }`
- **Appel :** dans **`standardOutStrategy`**, **`rabbitMQTraceStrategy`** et **`beelzebubCloudStrategy`**. Si `LOKI_URL` est défini, l’envoi vers Loki est fait quelle que soit la stratégie active.

### 4.2 Fonction `pushToLoki`

- **URL :**  
  - `LOKI_URL` = base (ex. `http://loki.railway.internal:3100`).  
  - Si l’URL ne contient pas déjà `/loki/api/v1/push`, on fait :  
    `strings.TrimSuffix(lokiURL, "/") + "/loki/api/v1/push"`.
- **Corps (Loki push API) :**
  ```json
  {
    "streams": [{
      "stream": { "service": "beelzebub" },
      "values": [ [ "<timestamp_nanosecondes>", "<ligne_JSON>" ] ]
    }]
  }
  ```
- **Ligne JSON (`lokiLogLine`)** :  
  - Champs : `msg`, `source_ip`, `request_uri`, `user_agent`, `http_method`, `body`, `headers`, `handler`, `description`, `datetime`, `id`, `host`, `protocol`, `status`.  
  - Remplis à partir de `tracer.Event` (ex. `event.Msg`, `event.SourceIp`, etc.).

### 4.3 Correspondance avec les dashboards Grafana / LogQL

- **Label de stream :** `service="beelzebub"` → utilisable dans LogQL : `{service="beelzebub"}`.
- **Filtre de contenu :** les panneaux utilisent par ex. `|= "HTTP New request"` ; `msg` dans `lokiLogLine` reprend `event.Msg`, donc `"HTTP New request"` ou `"HTTPS New Request"` selon le cas.
- **Champs pour `| json` et `sum by (source_ip)` etc. :**  
  - `source_ip`, `request_uri`, `user_agent`, `http_method` sont en racine du JSON poussé, donc compatibles avec les requêtes du type  
    `{service="beelzebub"} |= "HTTP New request" | json | sum by (source_ip) (...)`.

### 4.4 Résumé Loki

| Élément | Fichier / lieu |
|--------|----------------|
| Décision d’envoyer | `builder/director.go` : `standardOutStrategy`, `if LOKI_URL != ""` |
| Construction de la ligne | `pushToLoki` : struct `lokiLogLine` à partir de `tracer.Event` |
| Envoi | `pushToLoki` : `http.Post(pushURL, "application/json", ...)` vers `/loki/api/v1/push` |
| Label stream | `service": "beelzebub"` |
| Condition | Variable d’environnement **`LOKI_URL`** non vide ; **RabbitMQ et BeelzebubCloud désactivés** (sinon une autre stratégie est utilisée et `pushToLoki` n’est jamais appelé). |

---

## 5. Promtail (fichiers) – non utilisé sur Railway

**Fichier :** `loki-config/promtail-config.yaml`

- Promtail est prévu pour lire des **fichiers** : `__path__: /var/log/beelzebub/*.log`.
- Sur Railway, Beelzebub :
  - écrit dans `./logs` si le chemin est disponible dans le conteneur ;
  - et surtout logue sur **stdout** (capturé par Railway).
- Il n’y a **pas** de montage de `/var/log/beelzebub/` depuis le service Beelzebub vers Promtail sur Railway.  
→ Cette config Promtail **ne peut pas** alimenter Loki avec les logs Beelzebub dans votre setup actuel.  
→ L’envoi direct **Beelzebub → Loki** via `LOKI_URL` est la voie qui fonctionne sur Railway.

---

## 6. Synthèse : Prometheus vs Loki

| | Prometheus | Loki |
|---|------------|------|
| **Source dans le code** | `tracer` (compteurs) + `promhttp.Handler()` sur `/metrics` | `standardOutStrategy` → `pushToLoki` (si `LOKI_URL` défini) |
| **Déclenchement** | À chaque `TraceEvent` (HTTP, SSH, TCP, MCP) | À chaque `standardOutStrategy(event)` (donc à chaque événement quand cette stratégie est active) |
| **Données** | Compteurs agrégés (beelzebub_events_total, beelzebub_http_events_total, …) | Ligne de log par événement (msg, source_ip, request_uri, user_agent, …) |
| **Accès** | Scrape HTTP sur `https://<domaine>/metrics` | Push HTTP vers `LOKI_URL` + `/loki/api/v1/push` |
| **Prérequis** | Rien de plus (exposition du port du honeypot) | `LOKI_URL` défini, RabbitMQ et BeelzebubCloud désactivés |

---

## 7. Checklist d’intégration

### Prometheus

- [x] Compteurs dans `tracer` et `/metrics` sur le serveur HTTP (8080 / PORT).
- [ ] Prometheus scrape l’URL du service (ex. `https://3il-ingenieurs.site` avec `metrics_path: /metrics`).
- [ ] Grafana a une source Prometheus pointant vers ce Prometheus.

### Loki

- [ ] `LOKI_URL` défini (ex. `http://loki.railway.internal:3100`) dans les variables du service Beelzebub.
- [ ] RabbitMQ et BeelzebubCloud **désactivés** (pour que `standardOutStrategy` soit utilisée).
- [ ] Redéploiement de Beelzebub après ajout de `LOKI_URL`.
- [ ] Trafic de test (requêtes HTTP vers le honeypot) pour générer des événements.
- [ ] Dans Grafana Explore (Loki) : `{service="beelzebub"}` et `{service="beelzebub"} |= "HTTP New request"` retournent des lignes.

---

## 8. Références dans le code

| Rôle | Fichier | Fonction / bloc |
|------|---------|------------------|
| Compteurs Prometheus | `tracer/tracer.go` | `GetInstance`, `TraceEvent`, `updatePrometheusCounters` |
| Exposition /metrics (honeypot) | `protocols/strategies/HTTP/http.go` | `Init` → `serverMux.HandleFunc("/metrics", ...)` |
| Exposition /metrics (port 2112) | `builder/builder.go` | `Run` → goroutine `http.Handle(..., promhttp.Handler())`, `ListenAndServe(Prometheus.Port)` |
| Envoi d’événement (HTTP) | `protocols/strategies/HTTP/http.go` | `traceRequest` → `tr.TraceEvent(event)` |
| Config logger (stdout + fichier, JSON) | `builder/builder.go` | `buildLogger` |
| Log « New Event » + push Loki | `builder/director.go` | `standardOutStrategy`, `pushToLoki`, `lokiLogLine` |
| Config Prometheus / logging | `configurations/beelzebub.yaml` | `core.logging`, `core.prometheus`, `core.tracings` |

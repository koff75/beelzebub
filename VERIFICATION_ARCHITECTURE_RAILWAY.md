# Vérification architecture et variables – Railway (zoological-dedication)

*Vérification via Railway CLI (`railway variable list -s <service>`, `railway service status --all`).*

---

## 1. Services (production)

| Service     | Statut  | Rôle                                      |
|------------|---------|-------------------------------------------|
| beelzebub  | SUCCESS | Honeypot n8n, expose /metrics, push Loki  |
| Prometheus | SUCCESS | Scrape métriques, stockage                 |
| Loki       | SUCCESS | Agrégation logs (reçoit le push Beelzebub)|
| Tempo      | SUCCESS | Tracing                                   |
| Grafana    | SUCCESS | Dashboards, Explore                        |

---

## 2. Beelzebub – variables

| Variable            | Valeur                                  | OK |
|---------------------|-----------------------------------------|----|
| **LOKI_URL**        | `http://loki.railway.internal:3100`     | ✅ |
| **PORT**            | `8080`                                  | ✅ |
| **OPEN_AI_SECRET_KEY** | (défini)                            | ✅ |
| RAILWAY_PUBLIC_DOMAIN | `3il-ingenieurs.site`                | —  |
| RAILWAY_PRIVATE_DOMAIN | `beelzebub.railway.internal`       | —  |

- **LOKI_URL** : correspond à **Loki** (`loki.railway.internal:3100`). Le push des logs depuis Beelzebub vers Loki est correctement configuré.

---

## 3. Loki – variables (référence)

| Variable               | Valeur                   |
|------------------------|--------------------------|
| **PORT**               | `3100`                   |
| **RAILWAY_PRIVATE_DOMAIN** | `loki.railway.internal` |

→ Beelzebub utilise `http://loki.railway.internal:3100` = **correct**.

---

## 4. Grafana – variables (datasources)

| Variable                  | Valeur                                                   |
|---------------------------|----------------------------------------------------------|
| **LOKI_INTERNAL_URL**     | `http://loki.railway.internal:3100`                      |
| **PROMETHEUS_INTERNAL_URL** | `http://prometheus-aae6f39c.railway.internal:9090`    |
| **TEMPO_INTERNAL_URL**    | `http://tempo.railway.internal:3200`                     |
| RAILWAY_PUBLIC_DOMAIN     | `grafana-production-b017.up.railway.app`                 |

→ Les datasources Grafana (Loki, Prometheus, Tempo) pointent vers les bons services en interne.

---

## 5. Prometheus – variables (référence)

| Variable               | Valeur                                |
|------------------------|---------------------------------------|
| **PORT**               | `9090`                                |
| **RAILWAY_PRIVATE_DOMAIN** | `prometheus-aae6f39c.railway.internal` |
| RAILWAY_PUBLIC_DOMAIN  | `prometheus-production-17c8.up.railway.app` |

→ Grafana utilise `http://prometheus-aae6f39c.railway.internal:9090` = **correct**.

---

## 6. Schéma de flux

```
                    ┌─────────────────────────────────────────────────────────┐
                    │                    RAILWAY (zoological-dedication)        │
                    │                     env: production                       │
                    └─────────────────────────────────────────────────────────┘

  Internet                beelzebub                    Loki
  ─────────               ─────────                   ────
  https://                    │                         │
  3il-ingenieurs.site ──────►│ :8080                   │
       │                      │ /, /metrics, /rest/*   │
       │                      │ /form/*, /webhook/*    │
       │                      │                         │
       │                      │  LOKI_URL              │
       │                      │  http://loki.           │
       │                      │  railway.internal:3100 │
       │                      │  ─────────────────────►│ :3100
       │                      │       POST /loki/api/   │
       │                      │            v1/push     │
       │                      │                         │
       │                      │                         │
       │    Prometheus        │                         │
       │    scrape            │                         │
       │◄─────────────────────│ /metrics                │
       │  (depuis config       │                         │
       │   Prometheus,         │                         │
       │   ex. 3il-ingenieurs. │                         │
       │   site)               │                         │
       │                      │                         │
       │                      │                         │
       │    Grafana            │                         │
       │    datasources        │                         │
       │    (Loki, Prometheus, │                         │
       │     Tempo)            │                         │
       │◄──────────────────────┴─────────────────────────┘
       │   grafana-production-b017.up.railway.app
       │
```

---

## 7. Résumé

- **LOKI_URL** sur Beelzebub : `http://loki.railway.internal:3100` → **OK**, cohérent avec Loki.
- **Architecture** : beelzebub, Prometheus, Loki, Tempo, Grafana en SUCCESS.
- **Grafana** : LOKI_INTERNAL_URL, PROMETHEUS_INTERNAL_URL, TEMPO_INTERNAL_URL cohérents avec les services.

Pour vérifier que les logs arrivent dans Loki après trafic sur `https://3il-ingenieurs.site` :

- Grafana → **Explore** → **Loki** → `{service="beelzebub"}` ou `{service="beelzebub"} |= "HTTP New request"`.

---

## 8. Script `configure-loki-railway.ps1`

- Utilise `railway variable set -s beelzebub "LOKI_URL=..."` (pas de `railway service`).
- Prérequis : `railway link` (projet) depuis le dossier du dépôt.
- Pour reconfigurer :  
  `.\configure-loki-railway.ps1`  
  ou  
  `.\configure-loki-railway.ps1 -LokiUrl "http://loki.railway.internal:3100"`

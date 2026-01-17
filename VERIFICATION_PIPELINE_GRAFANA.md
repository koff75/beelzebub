# Vérification de bout en bout – Pipeline Grafana / Beelzebub

Le **dashboard IP Analysis** (et les panneaux Loki des autres dashboards) restent vides tant que les logs Beelzebub n’arrivent pas dans **Loki**. Voici comment vérifier chaque maillon et corriger.

---

## 1. Chaîne de données

```
Beelzebub (stdout)  ──?──>  Loki  ──>  Grafana (IP Analysis, etc.)
        │
        └──>  /metrics  ──>  Prometheus  ──>  Grafana (Overview, métriques)
```

- **Prometheus** : Beelzebub expose `/metrics` sur le port HTTP (8080). Prometheus scrape cette cible.  
  → Les panneaux **Prometheus** (Overview : Total Events, Events by Protocol, etc.) peuvent fonctionner.

- **Loki** : Beelzebub écrit en JSON sur **stdout**. Ces logs doivent être **envoyés à Loki**.  
  → Sans envoi vers Loki, les panneaux **Loki** (IP Analysis, Top IPs, Recent Events, etc.) restent vides.

---

## 2. Vérifications dans Grafana (Explore)

### 2.1 Prometheus

1. **Explore** → source **Prometheus**.
2. Requête :  
   `beelzebub_events_total`
3. **Run query**.

- Si vous avez une **valeur** (ex. 57) : Prometheus scrape bien Beelzebub, la partie **métriques** fonctionne.
- Si **No data** :  
  - Prometheus ne scrape pas Beelzebub (cible down ou mauvaise URL dans `prometheus.yml`),  
  - ou Beelzebub n’expose pas `/metrics` sur l’URL utilisée par Prometheus.

### 2.2 Loki

1. **Explore** → source **Loki**.
2. Requêtes à tester, une par une :
   - `{service="beelzebub"}`
   - `{service="beelzebub"} |= "HTTP New request"`
   - `{}` ou `{job=~".+"}` (pour voir si Loki a *quelque* log)

- Si **aucun résultat** pour `{service="beelzebub"}` :  
  **Aucun log Beelzebub n’est envoyé à Loki.**  
  C’est la cause la plus probable d’un dashboard IP Analysis vide.

---

## 3. Pourquoi Loki est vide ?

- Beelzebub logue en JSON sur **stdout** (champs `event`, `status`, etc.).
- Sur **Railway**, stdout est affiché dans les **Deploy Logs**, mais n’est **pas** automatiquement envoyé à Loki.
- La config **Promtail** du projet lit des fichiers du type `/var/log/beelzebub/*.log`.  
  Sur Railway, Beelzebub n’écrit pas dans ces fichiers → Promtail n’a rien à envoyer.

Donc : **sans mécanisme d’envoi des logs vers Loki, le dashboard IP Analysis reste vide.**

---

## 4. Solution : envoi des logs Beelzebub vers Loki

Pour que les logs arrivent dans Loki avec le label `service="beelzebub"`, il faut qu’**Beelzebub envoie lui‑même** chaque événement à l’API Loki (`/loki/api/v1/push`).

- Une **variable d’environnement** `LOKI_URL` a été ajoutée (ex. `http://loki.railway.internal:3100`).
- Si `LOKI_URL` est défini, Beelzebub envoie chaque événement (dont `"HTTP New request"`) à Loki, en plus du log stdout.

### 4.1 Configuration sur Railway

**Option A – Script (recommandé)**

Dans le dépôt Beelzebub, à la racine :

```powershell
.\configure-loki-railway.ps1
```

Par défaut, cela définit `LOKI_URL=http://loki.railway.internal:3100`. Si votre Loki a un autre hostname :

```powershell
.\configure-loki-railway.ps1 -LokiUrl "http://loki-xxxx.railway.internal:3100"
```

Puis redéployer (push, ou `railway up`).

**Option B – À la main**

1. Service **Beelzebub** → **Variables**.
2. Ajouter :
   - **Nom** : `LOKI_URL`
   - **Valeur** : `http://loki.railway.internal:3100`  
     (à adapter si votre service Loki a un autre hostname/port).

3. Redéployer Beelzebub.

### 4.2 Format des logs envoyés à Loki

Chaque log poussé vers Loki contient notamment :

- `msg` : `"HTTP New request"` (ou `"HTTPS New Request"`) pour les requêtes HTTP(S).
- `source_ip`, `request_uri`, `user_agent`, `http_method`, etc.

Les requêtes LogQL du dashboard IP Analysis (`{service="beelzebub"} |= "HTTP New request" | json` et `sum by (source_ip)...`) sont faites pour ce format.

---

## 5. Vérification après mise en place de LOKI_URL

1. Redéployer Beelzebub avec `LOKI_URL` défini.
2. Générer un peu de trafic :  
   ouvrir `https://3il-ingenieurs.site`, faire quelques requêtes (/, /rest/settings, /form/xxx, etc.).
3. Dans Grafana **Explore** → **Loki** :
   - `{service="beelzebub"}`
   - `{service="beelzebub"} |= "HTTP New request"`

Si des lignes apparaissent, le pipeline Beelzebub → Loki est bon.

4. Ouvrir le **dashboard IP Analysis** :  
   les panneaux (Most Active IPs, Requests per IP, etc.) devraient se remplir.

---

## 6. Récapitulatif des contrôles

| Étape | Où | Action | Si OK |
|-------|-----|--------|-------|
| 1 | Grafana → Explore → Prometheus | `beelzebub_events_total` | Valeur numérique |
| 2 | Grafana → Explore → Loki | `{service="beelzebub"}` | Lignes de logs |
| 3 | Dashboard Overview | Panneaux Prometheus (Total Events, etc.) | Données |
| 4 | Dashboard IP Analysis | Tous les panneaux | Données |
| 5 | Dashboard Exploit Detection | Panneaux Loki | Données |

---

## 7. Si Prometheus ne remonte rien

- Vérifier dans **Prometheus** (UI ou config) que le job `beelzebub` existe et que la cible est **UP**.
- Vérifier que l’URL de scrape (ex. `beelzebub:8080` ou l’URL interne Railway de Beelzebub) est joignable depuis le conteneur Prometheus (réseau interne Railway).

---

## 8. Si Loki ne reçoit toujours rien après LOKI_URL

- Vérifier que `LOKI_URL` est bien définie dans les variables du service Beelzebub.
- Vérifier que, depuis le conteneur Beelzebub, `http://loki.railway.internal:3100` (ou votre URL) est atteignable (réseau Railway).
- Consulter les **logs Beelzebub** (Railway) : en cas d’échec d’envoi, des messages de type `debug` peuvent apparaître (selon la configuration du logger).

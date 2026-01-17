# Diagnostic : aucun log Beelzebub dans Loki

Si `{service="beelzebub"}` dans Grafana Explore (Loki) ne renvoie rien, suivre cette checklist.

---

## 1. Au démarrage de Beelzebub (logs Railway)

Dans **Railway** → **Beelzebub** → **Deploy Logs** (ou **HTTP Logs**), au démarrage du conteneur, vérifier :

- **`LOKI_URL is set, events will be pushed to Loki`**  
  → `LOKI_URL` est bien lu au démarrage. Si absent : variable non définie ou mauvais service/variables.

- **`Init service: n8n workflow...`** (ou équivalent)  
  → Le service HTTP et le tracer sont bien démarrés.

Si **aucune** de ces lignes n’apparaît, le déploiement ou la config (variables, binaire) est à revoir.

---

## 2. Après du trafic (requêtes HTTP)

Faire quelques requêtes sur `https://3il-ingenieurs.site` (/, /rest/settings, /form/x, etc.), puis dans les **logs Beelzebub** :

- **`"msg":"New Event"`** (ou `level=info ... New Event`)  
  → Les événements sont bien tracés.

- **`loki push: ...`** (niveau Warn)  
  → Le push a été tenté mais a échoué (erreur réseau, 4xx/5xx, etc.). Le message indique la cause.

Si vous voyez **`New Event`** mais **jamais** `loki push`, alors soit :
- `LOKI_URL` est vide au moment du traitement (peu probable si la ligne de démarrage est là),  
- soit le code déployé ne contient pas `pushToLoki` (vérifier le commit/branch déployé).

---

## 3. Déploiement et code

- Le **commit** avec `pushToLoki` (dans `builder/director.go`) doit être **poussé** sur le dépôt relié à Railway.
- **Railway** doit avoir **redéployé** après ce push (ou après un `railway up`).
- Vérifier que le **service** déployé est bien **Beelzebub** (et non un autre du projet).

---

## 4. Variables Beelzebub

- **`LOKI_URL`** = `http://loki.railway.internal:3100`  
  (ou l’URL interne de votre Loki si différent).

Pour lister les variables du service :

```powershell
railway variable list -s beelzebub --json
```

---

## 5. Loki : réception et format

- **Loki** doit être **UP** (Railway : service Loki en succès).
- Le push utilise le path **`/loki/api/v1/push`**.  
  Si vous voyez **`loki push: status 404`**, votre Loki est peut‑être servi sous **`/api/v1/push`** (sans le préfixe `/loki`). Dans ce cas, il faudra adapter le code pour utiliser ce path.
- Aucune auth n’est envoyée. Si Loki est en mode multi‑tenant ou protégé, il faudra ajouter les en‑têtes (ex. `X-Scope-OrgID`, etc.) dans `pushToLoki`.

---

## 6. Grafana / plage de temps

- **Plage** : essayer **Last 6 hours** ou **Last 24 hours** (au lieu de Last 1 hour).
- Requêtes à tester :
  - `{service="beelzebub"}`
  - `{service="beelzebub"} |= "HTTP New request"`
  - `{}` ou `{job=~".+"}`  
    → Pour voir si Loki a **d’autres** logs. Si oui, le souci est limité au push Beelzebub ou au label `service="beelzebub"`.

---

## 7. Résumé des causes fréquentes

| Symptôme | Piste |
|----------|--------|
| Pas de `LOKI_URL is set...` au démarrage | `LOKI_URL` non défini ou mauvais service |
| Pas de `New Event` après des requêtes | Problème HTTP / routing / config services |
| `New Event` mais pas de `loki push` | Code sans `pushToLoki` ou `LOKI_URL` vide à l’exécution |
| `loki push: status 404` | Path Loki différent (ex. `/api/v1/push`) |
| `loki push: connection refused` (ou équivalent) | Loki injoignable depuis Beelzebub (réseau, host/port) |
| `loki push: status 401/403` | Loki requiert une authentification / en‑têtes |

---

## 8. Vérification rapide après correctif

1. **Redéployer** Beelzebub (push ou `railway up`).
2. Vérifier dans les logs : **`LOKI_URL is set, events will be pushed to Loki`**.
3. Générer du trafic sur `https://3il-ingenieurs.site`.
4. Dans Grafana **Explore** → **Loki** :  
   `{service="beelzebub"}`, plage **Last 1 hour** (puis 6h/24h si besoin).

Si des lignes apparaissent, le pipeline Beelzebub → Loki est opérationnel.

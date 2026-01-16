# Guide du Honeypot n8n - CVE-2026-21858 (Ni8mare)

## Vue d'ensemble

Ce honeypot simule une instance n8n version 1.120.0 (vulnérable à CVE-2026-21858) pour capturer les tentatives d'exploitation en temps réel.

## CVE-2026-21858 (Ni8mare)

**Sévérité** : CVSS 10.0 (Critique)

**Description** : Vulnérabilité d'exécution de code à distance non authentifiée dans n8n via Content-Type confusion dans les Form Webhooks.

**Technique d'exploitation** :
- Envoi de requêtes POST avec `Content-Type: application/json` (au lieu de `multipart/form-data`)
- Contrôle du champ `filepath` dans le body JSON pour lire des fichiers arbitraires
- Chaîne d'exploitation : File Read → Database Read → JWT Forge → RCE

## Endpoints exposés

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/rest/settings` | GET | Fingerprinting de version (retourne 1.120.0) |
| `/rest/login` | POST | Capture des tentatives d'authentification |
| `/form/*` | POST | **Cible principale** de l'exploit CVE-2026-21858 |
| `/webhook/*` | POST | Webhooks n8n |
| `/webhook-test/*` | POST | Webhooks de test |
| `/api/v1/workflows` | GET | API workflows n8n |

## Format des réponses

### GET /rest/settings
Réponse JSON statique :
```json
{
  "version": "1.120.0",
  "n8n-version": "1.120.0",
  "instanceId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "timezone": "UTC"
}
```

### POST /form/* (Cible de l'exploit)
Le honeypot détecte les tentatives d'exploitation via :
- `Content-Type: application/json` (au lieu de `multipart/form-data`)
- Présence de `"filepath"` dans le body JSON
- Structure : `{"data": {}, "files": {"f-xxx": {"filepath": "/etc/passwd", ...}}}`

Réponse générée par LLM : Erreur JSON n8n réaliste

## Indicateurs de compromission (IoCs)

### Pattern de requête suspecte
```http
POST /form/submit HTTP/1.1
Content-Type: application/json
User-Agent: python-requests/2.32.5

{
  "data": {},
  "files": {
    "f-t8ebu1": {
      "filepath": "/etc/passwd",
      "originalFilename": "z0nojfcn.bin",
      "mimetype": "application/octet-stream",
      "size": 43492
    }
  }
}
```

### User-Agents suspects
- `python-requests/*` (scanners automatisés)
- User-Agents non-navigateur pour les endpoints /form/*

### IPs et ASN connus
- AS212238 (Datacamp Limited) - VPN/Proxy utilisé pour scanning
- IPs avec tags `tor`, `vpn` sur VirusTotal

## Détection

### Règle Sigma
```yaml
title: n8n CVE-2026-21858 Exploitation Attempt
detection:
  selection_method:
    cs-method: POST
  selection_path:
    cs-uri-stem|contains:
      - '/form/'
      - '/webhook/'
      - '/webhook-test/'
  selection_content_type:
    cs-content-type|contains: 'application/json'
  selection_body:
    request_body|contains: '"filepath":'
  condition: selection_method and selection_path and selection_content_type and selection_body
```

### Logs à surveiller
Dans Railway, filtrer les logs pour :
- `RequestURI` contenant `/form/`, `/webhook/`
- `Body` contenant `"filepath"`
- `Content-Type: application/json` avec POST vers ces endpoints

## Statistiques

Accéder aux métriques Prometheus :
```
https://beelzebub-production.up.railway.app/metrics
```

Métriques pertinentes :
- `beelzebub_http_events_total` - Total des requêtes HTTP
- `beelzebub_events_total` - Total des événements

## Timeline d'exploitation typique

1. **Reconnaissance** : `GET /rest/settings` pour vérifier la version
2. **Exploitation** : `POST /form/*` avec payload CVE-2026-21858
3. **Spray** : Tentatives sur multiples endpoints (/form/*, /webhook/*)

## Références

- [CVE-2026-21858](https://github.com/advisories/GHSA-xxxx) - GitHub Advisory
- [Cyera Research Labs - Ni8mare Writeup](https://www.cyera.com/research-labs/ni8mare)
- [Beelzebub Documentation](https://github.com/mariocandela/beelzebub)

## Configuration actuelle

- **Version simulée** : n8n 1.120.0 (vulnérable)
- **Port** : 8080 (ajusté automatiquement selon Railway PORT)
- **LLM** : OpenAI GPT-4o (pour générer des réponses n8n réalistes)
- **Logging** : Tous les événements sont loggés dans Railway

## Déploiement

Le honeypot est configuré pour Railway et s'ajuste automatiquement au port assigné via la variable d'environnement `PORT`.

Variables d'environnement requises :
- `PORT=8080` (obligatoire)
- `OPEN_AI_SECRET_KEY=sk-...` (pour le plugin LLM)

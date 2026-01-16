# Configuration Railway pour zoological-dedication

## Variables d'environnement requises

Pour le projet **zoological-dedication** sur Railway, configurez ces variables dans l'onglet **Variables** :

### Variables OBLIGATOIRES

```bash
PORT=8080
```

### Variables OPTIONNELLES (pour le honeypot bancaire avec LLM)

```bash
OPEN_AI_SECRET_KEY=sk-votre-cle-api-openai
```

## Vérification de la configuration

1. **Port d'écoute** : Le code ajuste automatiquement le port selon la variable `PORT` de Railway
2. **Fichier de configuration** : Seul `http-8080-banking.yaml` est présent dans `configurations/services/`
3. **Domaine public** : Généré dans Settings > Networking > Generate Domain

## Commandes Railway CLI (si installé)

```bash
# Vérifier les variables
railway variables

# Définir PORT (syntaxe correcte avec --set)
railway variables --set "PORT=8080"

# Définir OPEN_AI_SECRET_KEY
railway variables --set "OPEN_AI_SECRET_KEY=sk-votre-cle"

# Pour un service spécifique (si nécessaire)
railway variables --set "PORT=8080" --service beelzebub

# Voir les logs
railway logs

# Voir le statut
railway status
```

## URL de production

Une fois configuré, votre honeypot sera accessible sur :
- **URL Railway** : `beelzebub-production.up.railway.app` (ou l'URL générée)
- **Test** : `curl https://beelzebub-production.up.railway.app/`

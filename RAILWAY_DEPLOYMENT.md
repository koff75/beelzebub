# Guide de déploiement Beelzebub sur Railway

Ce guide vous explique comment déployer Beelzebub sur Railway avec la configuration optimale.

## 🚀 Déploiement rapide

### 1. Préparation du dépôt

Avant de déployer sur Railway, vous devez décider quelle configuration utiliser :

#### Option A : Honeypot bancaire avec LLM (recommandé)
- **Fichier à garder** : `configurations/services/http-8080-banking.yaml`
- **Fichiers à supprimer ou renommer** : Tous les autres fichiers dans `configurations/services/` (sauf `http-8080-banking.yaml`)

#### Option B : Honeypot HTTP simple
- **Fichier à garder** : `configurations/services/http-8080.yaml`
- **Fichiers à supprimer ou renommer** : Tous les autres fichiers dans `configurations/services/`

**Note** : Railway déploie tout le contenu du dépôt. Si vous gardez plusieurs fichiers de configuration, Beelzebub essaiera de démarrer tous les services, ce qui peut causer des conflits de ports.

### 2. Création du projet Railway

1. Allez sur [Railway Dashboard](https://railway.app/)
2. Cliquez sur **New Project** > **Deploy from GitHub repo**
3. Sélectionnez votre dépôt `koff75/beelzebub`
4. Railway détectera automatiquement le `Dockerfile` à la racine
5. Cliquez sur **Deploy Now**

### 3. Configuration des variables d'environnement

Dans l'onglet **Variables** de votre service Railway, ajoutez :

| Variable | Valeur | Description |
| --- | --- | --- |
| `PORT` | `8080` | **OBLIGATOIRE** - Railway injecte cette variable, et notre code l'utilise automatiquement pour ajuster le port d'écoute |
| `OPEN_AI_SECRET_KEY` | `sk-...` | **Optionnel** - Requis uniquement si vous utilisez le plugin LLM (honeypot bancaire) |

**Important** : Le code a été modifié pour utiliser automatiquement la variable d'environnement `PORT`. Même si votre fichier de configuration indique `:8080`, Railway peut assigner un port différent, et l'application s'adaptera automatiquement.

### 4. Exposition du service

1. Allez dans l'onglet **Settings** de votre service
2. Dans la section **Networking**, cliquez sur **Generate Domain**
3. Cela créera une URL du type `beelzebub-production.up.railway.app`

### 5. Vérification

Une fois déployé, vous pouvez :

- **Accéder au honeypot** : Visitez l'URL générée par Railway
- **Voir les logs** : Consultez l'onglet **Logs** de Railway pour voir les tentatives d'intrusion en temps réel
- **Tester le honeypot bancaire** : Essayez d'accéder à `/login` ou `/dashboard` pour voir les réponses du LLM

## 🔧 Configuration avancée

### Utiliser le honeypot bancaire avec LLM

Le fichier `configurations/services/http-8080-banking.yaml` est préconfiguré pour :

- Afficher une page de connexion bancaire réaliste sur `/` ou `/login`
- Utiliser le plugin LLM pour générer des réponses dynamiques pour toutes les autres requêtes
- Valider les entrées et sorties pour détecter les tentatives d'injection de prompt

**Prérequis** :
- Variable d'environnement `OPEN_AI_SECRET_KEY` configurée dans Railway
- Modèle LLM : `gpt-4o` (configurable dans le fichier YAML)

### Modifier le prompt LLM

Vous pouvez personnaliser le comportement du honeypot en modifiant le champ `prompt` dans `http-8080-banking.yaml` :

```yaml
plugin:
  prompt: |
    Votre prompt personnalisé ici...
```

## 🐛 Dépannage

### Le service ne démarre pas

1. **Vérifiez les logs** : L'onglet **Logs** de Railway affiche les erreurs de démarrage
2. **Vérifiez les variables d'environnement** : Assurez-vous que `PORT` est défini
3. **Vérifiez les fichiers de configuration** : Assurez-vous qu'un seul fichier de configuration HTTP est présent dans `configurations/services/`

### Le honeypot ne répond pas

1. **Vérifiez l'URL** : Utilisez l'URL générée par Railway (pas `localhost:8080`)
2. **Vérifiez les logs** : Les requêtes HTTP sont loggées dans l'onglet **Logs**
3. **Testez avec curl** : `curl https://votre-url.railway.app/`

### Erreurs LLM

Si vous utilisez le plugin LLM et obtenez des erreurs :

1. **Vérifiez la clé API** : La variable `OPEN_AI_SECRET_KEY` doit être valide
2. **Vérifiez les quotas** : Assurez-vous que votre compte OpenAI a des crédits disponibles
3. **Vérifiez le modèle** : Le modèle `gpt-4o` doit être accessible avec votre clé API

## 📝 Notes importantes

- **Image Docker** : Beelzebub utilise une image `scratch` (ultra-légère), donc vous ne pouvez pas vous connecter au conteneur avec `docker exec`
- **Logs** : Tous les logs sont disponibles dans l'interface Railway
- **Port dynamique** : Le code ajuste automatiquement le port d'écoute selon la variable `PORT` de Railway
- **Sécurité** : Ne commitez jamais de vraies clés API dans le dépôt. Utilisez toujours les variables d'environnement Railway

## 🔗 Ressources

- [Documentation Railway](https://docs.railway.app/)
- [Documentation Beelzebub](https://github.com/mariocandela/beelzebub)
- [API OpenAI](https://platform.openai.com/docs/api-reference)

# Vérification du fonctionnement du LLM OpenAI

## 🔍 Comment vérifier si le LLM fonctionne

### Indicateurs que le LLM fonctionne ✅

1. **Messages d'erreur réalistes** : Si vous voyez des messages comme :
   - "Échec de la Connexion - Les identifiants fournis ne sont pas valides"
   - "Erreur d'authentification"
   - Pages HTML complètes avec style
   
   → **Le LLM fonctionne !** Ces messages sont générés par GPT-4o.

2. **Pas de "404 Not Found!"** : Si vous ne voyez PAS "404 Not Found!" comme réponse, c'est bon signe.

### Indicateurs que le LLM ne fonctionne pas ❌

1. **Réponse "404 Not Found!"** : Si toutes les requêtes retournent "404 Not Found!", le LLM ne fonctionne pas.

2. **Erreurs dans les logs** :
   - `ExecuteModel error: openAIKey is empty`
   - `ExecuteModel error: ...` (autres erreurs)
   - Erreurs HTTP de l'API OpenAI

## 📋 Vérification étape par étape

### 1. Vérifier la variable d'environnement dans Railway

```bash
railway variables
```

Vous devez voir :
- `PORT=8080`
- `OPEN_AI_SECRET_KEY=sk-...` (avec votre vraie clé)

### 2. Vérifier les logs Railway

Dans l'interface Railway, cherchez dans les logs :

**Si le LLM fonctionne :**
- Pas d'erreurs "ExecuteModel error"
- Pas d'erreurs "openAIKey is empty"
- Beaucoup de "New Event" (requêtes capturées)

**Si le LLM ne fonctionne pas :**
- `level=error msg="ExecuteModel error: openAIKey is empty"`
- `level=error msg="ExecuteModel error: ..."`
- Les réponses sont "404 Not Found!"

### 3. Tester manuellement

1. Allez sur `https://beelzebub-production.up.railway.app/`
2. Entrez des identifiants bidon
3. Cliquez sur "Se connecter"

**Si vous voyez :**
- Une page HTML d'erreur d'authentification stylée
- Un message en français réaliste
- Un bouton "Retour à la page de connexion"

→ **Le LLM fonctionne !** ✅

**Si vous voyez :**
- Juste "404 Not Found!"
- Pas de HTML stylé

→ **Le LLM ne fonctionne pas** ❌

## 🔧 Diagnostic des problèmes

### Problème : "openAIKey is empty"

**Solution :**
```bash
railway variables --set "OPEN_AI_SECRET_KEY=sk-votre-cle-openai"
```

### Problème : Erreurs API OpenAI

**Causes possibles :**
1. Clé API invalide ou expirée
2. Quota OpenAI dépassé
3. Modèle `gpt-4o` non accessible avec votre clé

**Solution :**
1. Vérifiez votre clé sur https://platform.openai.com/api-keys
2. Vérifiez vos quotas sur https://platform.openai.com/usage
3. Essayez avec un autre modèle (ex: `gpt-3.5-turbo`)

### Problème : Timeout ou erreurs réseau

**Solution :**
- Vérifiez que Railway peut accéder à l'API OpenAI (pas de firewall)
- Vérifiez les logs pour les erreurs réseau

## 📊 Logs détaillés

Pour voir plus de détails dans les logs Railway :

1. **Filtrez par "error"** : Cherchez toutes les lignes contenant "error"
2. **Filtrez par "ExecuteModel"** : Cherchez les appels au LLM
3. **Filtrez par "HTTP New request"** : Voir toutes les requêtes capturées

## ✅ Conclusion

D'après vos logs :
- ✅ Beaucoup de "New Event" → Les requêtes sont capturées
- ✅ Pas d'erreurs visibles → Le LLM semble fonctionner
- ✅ Vous voyez des messages d'erreur réalistes → Le LLM génère bien les réponses

**Le LLM OpenAI fonctionne probablement !** 🎉

Pour confirmer à 100%, testez une requête et vérifiez que vous obtenez une réponse HTML stylée et non "404 Not Found!".

# Commandes Railway CLI pour zoological-dedication

## ✅ Commandes correctes

### 1. Définir la variable PORT (OBLIGATOIRE)

```powershell
railway variables --set "PORT=8080"
```

### 2. Définir la variable OPEN_AI_SECRET_KEY (Optionnel, pour le LLM)

```powershell
railway variables --set "OPEN_AI_SECRET_KEY=sk-votre-cle-openai"
```

### 3. Vérifier les variables définies

```powershell
railway variables
```

### 4. Voir les logs en temps réel

```powershell
railway logs
```

### 5. Voir le statut du projet

```powershell
railway status
```

## 📝 Notes importantes

- Utilisez des **guillemets doubles** autour de `"KEY=VALUE"`
- Utilisez `--set` (avec deux tirets) et non `set`
- Vous pouvez définir plusieurs variables en une seule commande :
  ```powershell
  railway variables --set "PORT=8080" --set "OPEN_AI_SECRET_KEY=sk-..."
  ```

## 🔧 Si vous avez plusieurs services

Si vous avez plusieurs services dans votre projet, spécifiez le service :

```powershell
railway variables --set "PORT=8080" --service beelzebub
```

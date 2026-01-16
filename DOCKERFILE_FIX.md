# Correction du Dockerfile pour Railway

## Problème identifié

L'erreur était :
```
Error during ReadConfigurationsCore: : in file ./configurations/beelzebub.yaml: open ./configurations/beelzebub.yaml: no such file or directory
```

## Solution appliquée

Le Dockerfile a été modifié pour copier les fichiers de configuration dans l'image finale :

```dockerfile
COPY --from=builder /build/configurations /configurations
```

## Changements dans le Dockerfile

1. ✅ Ajout de la copie des configurations depuis le stage builder
2. ✅ Les fichiers sont maintenant disponibles dans `/configurations/` dans le conteneur

## Prochaines étapes

1. **Commit et push sur GitHub** :
   ```bash
   git add Dockerfile
   git commit -m "Fix: Ajouter les fichiers de configuration dans l'image Docker"
   git push
   ```

2. **Railway redéploiera automatiquement** depuis GitHub

3. **Vérifiez les logs** après le redéploiement pour confirmer que l'application démarre correctement

## Vérification

Après le redéploiement, vous devriez voir dans les logs :
- ✅ `Init service: Banque en ligne - Interface de connexion`
- ✅ `Adjusted address from environment PORT: :XXXX` (où XXXX est le port Railway)

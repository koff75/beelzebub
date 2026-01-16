# Identifiants pour le Honeypot Bancaire

## 🔐 Identifiants acceptés (factices)

Le honeypot accepte ces identifiants pour simuler une connexion réussie :

| Username | Password | Description |
|----------|----------|-------------|
| `admin` | `admin123` | Compte administrateur factice |
| `test` | `test123` | Compte de test factice |
| `demo` | `demo123` | Compte démo factice |

## ✅ Comportement avec identifiants acceptés

Quand vous utilisez un de ces identifiants :
- **Réponse** : Page HTML de succès avec message "Connexion réussie"
- **Redirection** : Lien vers `/dashboard` pour accéder au tableau de bord factice
- **Tableau de bord** : Données bancaires factices (soldes, transactions, etc.)

## ❌ Comportement avec autres identifiants

Avec n'importe quel autre identifiant :
- **Réponse** : Page d'erreur d'authentification
- **Message** : "Échec de la Connexion - Les identifiants fournis ne sont pas valides"

## 🎯 Objectif du honeypot

Ces identifiants sont **factices** et servent à :
- Simuler un comportement bancaire réaliste
- Capturer les tentatives d'intrusion
- Analyser les techniques d'attaque
- Collecter des statistiques sur les attaquants

**Important** : Aucune vraie authentification n'est effectuée. Tous les identifiants sont traités par le LLM pour générer des réponses réalistes.

## 📊 Statistiques

Toutes les tentatives de connexion (réussies ou échouées) sont :
- Loggées dans Railway
- Comptabilisées dans les métriques Prometheus (`/metrics`)
- Traçables avec IP source, User-Agent, timestamp, etc.

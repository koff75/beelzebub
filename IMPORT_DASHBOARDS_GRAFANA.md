# Import manuel des dashboards Beelzebub dans Grafana

Le dossier **Beelzebub** existe mais les dashboards ne sont pas chargés automatiquement par le provisioning. Voici comment les ajouter à la main.

---

## Étapes

### 1. Ouvrir l’import

1. Dans Grafana : **Dashboards** (menu gauche) > **New** > **Import**  
   **ou** **Dashboards** > **Browse** > **Import**.

### 2. Importer chaque dashboard

Pour **chaque** fichier ci‑dessous :

1. Cliquez sur **Upload JSON file**.
2. Choisissez le fichier (chemins possibles) :
   - `beelzebub/grafana-dashboards/beelzebub-overview.json`
   - `beelzebub/grafana-dashboards/beelzebub-exploit-detection.json`
   - `beelzebub/grafana-dashboards/beelzebub-ip-analysis.json`
3. Cliquez sur **Load**.
4. Vérifiez :
   - **Folder** : **Beelzebub**
   - **Prometheus** : UID `prometheus`
   - **Loki** : UID `loki`
5. Cliquez sur **Import**.

---

## Fichiers à importer (dans l’ordre)

| Dashboard | Fichier | Rôle |
|-----------|---------|------|
| **Beelzebub Overview** | `grafana-dashboards/beelzebub-overview.json` | Vue d’ensemble (métriques + logs) |
| **Beelzebub Exploit Detection** | `grafana-dashboards/beelzebub-exploit-detection.json` | Détection CVE‑2026‑21858 |
| **Beelzebub IP Analysis** | `grafana-dashboards/beelzebub-ip-analysis.json` | Analyse des IP |

---

## UIDs des datasources

Les dashboards utilisent ces UIDs. À contrôler dans **Configuration** > **Data sources** :

- **Prometheus** → UID : `prometheus`
- **Loki** → UID : `loki`
- **Tempo** → UID : `tempo`

Si un dashboard affiche "Datasource not found", éditez la source concernée et définissez le bon UID.

---

## Emplacement des JSON

Dans ce projet :

```
beelzebub/grafana-dashboards/
├── beelzebub-overview.json
├── beelzebub-exploit-detection.json
└── beelzebub-ip-analysis.json
```

Dans le fork `railway-grafana-stack` :

```
grafana/provisioning/dashboards/
├── beelzebub-overview.json
├── beelzebub-exploit-detection.json
└── beelzebub-ip-analysis.json
```

---

## Après l’import

Les 3 dashboards doivent apparaître dans **Dashboards** > **Beelzebub**.  
Si les panneaux sont vides, vérifiez que Prometheus scrape bien beelzebub et que Loki reçoit les logs.

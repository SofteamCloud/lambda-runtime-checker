# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-08-18

### Ajouté
- Script principal `check-lambda-runtimes.sh` pour identifier les runtimes obsolètes
- Support pour les runtimes Python (3.8, 3.9) et Node.js (16.x, 18.x)
- Scan multi-comptes et multi-régions configurables
- Génération de rapports en format texte, CSV et résumé
- Filtrage par type de runtime (python, nodejs, all)
- Configuration des profils à ignorer (ex: profils SSO)
- Script de test `test-setup.sh` pour vérifier l'installation
- Documentation complète avec README.md
- Guide de contribution CONTRIBUTING.md
- Licence MIT open source
- Configuration Git avec .gitignore approprié

### Fonctionnalités
- ✅ Compatible bash 3.x (macOS et Linux)
- ✅ Gestion des erreurs et profils inaccessibles
- ✅ Messages colorés pour une meilleure lisibilité
- ✅ Rapports horodatés avec statistiques détaillées
- ✅ Support des régions AWS configurables
- ✅ Exclusion automatique des profils SSO

### Runtimes surveillés
- **Python 3.8**: EOL - Upgrade vers python3.12 ou python3.13
- **Python 3.9**: EOL 15 décembre 2025 - Upgrade vers python3.12 ou python3.13
- **Node.js 16.x**: EOL - Upgrade vers nodejs20.x ou nodejs22.x
- **Node.js 18.x**: EOL 30 avril 2025 - Upgrade vers nodejs20.x ou nodejs22.x

### Régions par défaut
- eu-north-1 (Europe - Stockholm)
- eu-west-3 (Europe - Paris)
- us-east-2 (US East - Ohio)
- eu-west-1 (Europe - Ireland)
- eu-central-1 (Europe - Frankfurt)
- us-east-1 (US East - N. Virginia)
- us-west-2 (US West - Oregon)

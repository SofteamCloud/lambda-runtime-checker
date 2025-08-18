# AWS Lambda Runtime Checker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Script-green.svg)](https://www.gnu.org/software/bash/)

Un script pour identifier les fonctions AWS Lambda utilisant des runtimes obsolètes ou bientôt obsolètes dans vos comptes AWS.

## 📋 Contexte

AWS a annoncé la fin de support pour Python 3.9 le 15 décembre 2025, suivant la fin de vie officielle de Python 3.9 le 30 octobre 2025. Ce script vous aide à identifier ces fonctions Lambda dans votre organisation AWS.

## ✨ Fonctionnalités

- 🔍 **Scan multi-comptes et multi-régions** : Analyse tous vos profils AWS configurés
- 📊 **Rapports détaillés** : Génère des rapports en format texte et CSV
- 🎯 **Filtrage flexible** : Recherche par type de runtime (Python, Node.js, ou tous)
- ⚙️ **Configuration simple** : Profils à ignorer configurables
- 🚀 **Compatible bash 3.x** : Fonctionne sur macOS et Linux
- 📈 **Résumés statistiques** : Vue d'ensemble par compte et région

## 🚀 Installation rapide

```bash
# Cloner le repository
git clone https://github.com/softeam/lambda-runtime-checker.git
cd lambda-runtime-checker

# Rendre les scripts exécutables
chmod +x *.sh

# Tester l'installation
./test-setup.sh

# Scanner vos fonctions Lambda Python
./check-lambda-runtimes.sh python
```

## 🛠️ Prérequis

- AWS CLI installé et configuré
- `jq` installé (`brew install jq` sur macOS)
- Profils AWS configurés dans `~/.aws/config`
- Permissions IAM pour lister les fonctions Lambda

## 📁 Fichiers

### `check-lambda-runtimes.sh`
Script principal pour identifier les fonctions Lambda avec des runtimes obsolètes.

### `test-setup.sh`
Script de test pour vérifier l'installation et la configuration.

### `reports/`
Dossier généré automatiquement contenant les rapports de scan.
**Note**: Ce dossier est exclu du versioning Git via `.gitignore`.

### `.gitignore`
Fichier de configuration Git pour exclure les rapports générés du versioning.

## 🚀 Utilisation

### 1. Tester l'installation

```bash
# Rendre les scripts exécutables
chmod +x *.sh

# Tester l'installation
./test-setup.sh
```

### 2. Identifier les fonctions avec runtimes obsolètes

```bash
# Scanner tous les runtimes obsolètes
./check-lambda-runtimes.sh

# Scanner uniquement Python
./check-lambda-runtimes.sh python

# Scanner uniquement Node.js
./check-lambda-runtimes.sh nodejs

# Afficher l'aide
./check-lambda-runtimes.sh --help
```

## 📊 Rapports Générés

Le script génère trois types de rapports dans le dossier `reports/` :

1. **Rapport détaillé** (`lambda_obsolete_runtimes_[filter]_[timestamp].txt`)
   - Informations complètes sur chaque fonction trouvée
   - Format lisible par l'humain

2. **Rapport CSV** (`lambda_obsolete_runtimes_[filter]_[timestamp].csv`)
   - Format tabulaire pour analyse dans Excel/Google Sheets
   - Colonnes : Account, Profile, Region, Function, Runtime, Status, ARN, LastModified

3. **Résumé** (`summary_[filter]_[timestamp].txt`)
   - Vue d'ensemble des résultats
   - Statistiques par compte et région

## 🎯 Runtimes Surveillés

### Python
- `python3.8` - ❌ EOL (End of Life)
- `python3.9` - ⚠️ EOL le 15 décembre 2025

### Node.js
- `nodejs16.x` - ❌ EOL (End of Life)
- `nodejs18.x` - ⚠️ EOL le 30 avril 2025

### Runtimes Recommandés
- **Python** : `python3.12` ou `python3.13`
- **Node.js** : `nodejs20.x` ou `nodejs22.x`

## 🌍 Régions Scannées

Le script scanne les régions suivantes (configurables dans le script) :
- `eu-north-1` (Europe - Stockholm)
- `eu-west-3` (Europe - Paris)
- `us-east-2` (US East - Ohio)
- `eu-west-1` (Europe - Ireland)
- `eu-central-1` (Europe - Frankfurt)
- `us-east-1` (US East - N. Virginia)
- `us-west-2` (US West - Oregon)


## 🔧 Personnalisation

### Modifier les régions scannées
Éditez la variable `regions` dans `check-lambda-runtimes.sh` :

```bash
regions=(
    "eu-west-1"
    "us-east-1"
    # Ajoutez vos régions
)
```

### Ajouter des runtimes à surveiller
Modifiez le tableau `OBSOLETE_RUNTIMES` dans `check-lambda-runtimes.sh` :

```bash
OBSOLETE_RUNTIMES=(
    ["python3.10"]="Bientôt obsolète - Upgrade recommandé"
    # Ajoutez d'autres runtimes
)
```

### Configurer les profils à ignorer
Modifiez la variable `IGNORED_PROFILES` dans `check-lambda-runtimes.sh` :

```bash
IGNORED_PROFILES=(
    "login"
    "sso-profile"
    "s3"
    # Ajoutez d'autres profils à ignorer
)
```

## 📝 Exemples de Sortie

### Résumé du scan
```
=== RÉSUMÉ DU SCAN ===
Date: 2024-01-15 14:30:00
Filtre appliqué: python
Régions scannées: eu-west-1 us-east-1

RÉSULTATS:
- Total des fonctions avec runtimes obsolètes: 5
- Nombre de comptes impactés: 2

DÉTAIL PAR COMPTE:
- prod-account: 3 fonction(s)
- dev-account: 2 fonction(s)
```

### Fonction trouvée
```
🔍 Trouvé: my-api-function (python3.9) - EOL December 15, 2025 - Upgrade to python3.12 or python3.13
```

## 🆘 Dépannage

### Erreur "Profil inaccessible"
- Vérifiez que le profil AWS existe : `aws configure list-profiles`
- Vérifiez les permissions : `aws sts get-caller-identity --profile <profile>`

### Erreur "Dépendances manquantes"
- Installez AWS CLI : [Guide d'installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Installez jq : `brew install jq` (macOS) ou `apt-get install jq` (Ubuntu)

### Permissions insuffisantes
Assurez-vous que vos profils AWS ont les permissions suivantes :
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:ListFunctions",
                "lambda:GetFunction"
            ],
            "Resource": "*"
        }
    ]
}
```

## 📞 Support

Pour toute question ou problème :
1. Consultez les logs d'erreur
2. Vérifiez les permissions AWS
3. Contactez l'équipe AWS Support si nécessaire

## 📚 Références

- [AWS Lambda Runtime Support Policy](https://docs.aws.amazon.com/lambda/latest/dg/runtime-support-policy.html)
- [Python 3.9 End of Life](https://devguide.python.org/versions/)
- [AWS Lambda Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)

## 🔄 Mise à jour des Fonctions

Une fois que vous avez identifié les fonctions à mettre à jour, vous pouvez :

1. **Via la Console AWS** : Modifier le runtime dans la configuration de la fonction
2. **Via AWS CLI** : 
   ```bash
   aws lambda update-function-configuration \
     --function-name <function-name> \
     --runtime python3.12 \
     --profile <profile> \
     --region <region>
   ```
3. **Via Infrastructure as Code** : Mettre à jour vos templates CloudFormation/SAM/Terraform

⚠️ **Important** : Testez toujours vos fonctions après la mise à jour du runtime pour vous assurer de la compatibilité.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

- 🐛 Signaler des bugs via les [Issues](../../issues)
- 💡 Proposer des améliorations
- 🔧 Soumettre des Pull Requests
- 📖 Améliorer la documentation

### Comment contribuer

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Auteurs

- **Softeam** - *Développement initial* - [Softeam](https://github.com/SofteamCloud)

## 🙏 Remerciements

- AWS pour la documentation sur les runtimes Lambda
- La communauté open source pour les outils et bonnes pratiques
- Tous les contributeurs qui aident à améliorer ce projet

---

**Développé avec ❤️ par [Softeam](https://softeam.com)**

# Guide de Contribution

Merci de votre intérêt pour contribuer au projet AWS Lambda Runtime Checker ! 🎉

## 🤝 Comment contribuer

### Signaler un bug

1. Vérifiez que le bug n'a pas déjà été signalé dans les [Issues](../../issues)
2. Créez une nouvelle issue avec le template "Bug Report"
3. Incluez autant de détails que possible :
   - Version du script
   - Système d'exploitation
   - Version d'AWS CLI
   - Messages d'erreur complets
   - Étapes pour reproduire le problème

### Proposer une amélioration

1. Créez une issue avec le template "Feature Request"
2. Décrivez clairement la fonctionnalité souhaitée
3. Expliquez pourquoi cette fonctionnalité serait utile
4. Proposez une implémentation si possible

### Soumettre du code

1. **Fork** le repository
2. **Clone** votre fork localement
3. Créez une **branche** pour votre fonctionnalité :
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```
4. **Développez** votre fonctionnalité
5. **Testez** vos modifications :
   ```bash
   ./test-setup.sh
   ```
6. **Committez** vos changements :
   ```bash
   git commit -m "feat: ajouter support pour runtime XYZ"
   ```
7. **Push** vers votre fork :
   ```bash
   git push origin feature/ma-nouvelle-fonctionnalite
   ```
8. Créez une **Pull Request**

## 📝 Standards de code

### Style de code

- Utilisez des **noms de variables explicites**
- **Commentez** le code complexe
- Suivez les **conventions bash** existantes
- Utilisez des **couleurs** pour les messages utilisateur
- Gérez les **erreurs** proprement

### Messages de commit

Utilisez le format [Conventional Commits](https://www.conventionalcommits.org/) :

- `feat:` pour une nouvelle fonctionnalité
- `fix:` pour une correction de bug
- `docs:` pour la documentation
- `style:` pour le formatage
- `refactor:` pour la refactorisation
- `test:` pour les tests
- `chore:` pour les tâches de maintenance

Exemples :
```
feat: ajouter support pour runtime nodejs22.x
fix: corriger l'analyse des profils avec espaces
docs: mettre à jour le README avec nouveaux exemples
```

### Tests

- Testez sur **macOS** et **Linux** si possible
- Vérifiez que `./test-setup.sh` passe
- Testez avec différents profils AWS
- Vérifiez que les rapports sont générés correctement

## 🔧 Configuration de développement

### Prérequis

- bash 3.x ou supérieur
- AWS CLI configuré
- jq installé
- Git

### Installation

```bash
git clone https://github.com/votre-username/lambda-runtime-checker.git
cd lambda-runtime-checker
chmod +x *.sh
./test-setup.sh
```

### Structure du projet

```
lambda-runtime-checker/
├── check-lambda-runtimes.sh    # Script principal
├── test-setup.sh               # Tests d'installation
├── README.md                   # Documentation
├── CONTRIBUTING.md             # Ce fichier
├── LICENSE                     # Licence MIT
├── .gitignore                  # Fichiers à ignorer
└── reports/                    # Rapports générés
    └── .gitkeep               # Maintient la structure
```

## 🐛 Debugging

### Activer le mode debug

```bash
# Ajouter en haut du script
set -x  # Affiche les commandes exécutées
```

### Logs utiles

- Vérifiez les permissions des fichiers
- Testez avec un seul profil AWS d'abord
- Utilisez `aws sts get-caller-identity` pour tester l'accès

## 📋 Checklist avant PR

- [ ] Le code suit les standards du projet
- [ ] Les tests passent (`./test-setup.sh`)
- [ ] La documentation est mise à jour
- [ ] Les messages de commit suivent les conventions
- [ ] Pas de données sensibles dans le code
- [ ] Le `.gitignore` est respecté

## 🆘 Besoin d'aide ?

- Consultez les [Issues existantes](../../issues)
- Créez une nouvelle issue avec le tag "question"
- Contactez les mainteneurs

## 🙏 Merci !

Chaque contribution, petite ou grande, est appréciée. Merci de rendre ce projet meilleur ! ❤️

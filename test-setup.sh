#!/bin/bash

# AWS Lambda Runtime Checker - Test Setup
# Copyright (c) 2024 Softeam
# Licensed under the MIT License - see LICENSE file for details
#
# Script de test pour vérifier l'installation et la configuration
# Usage: ./test-setup.sh

set -euo pipefail

# Couleurs pour l'affichage
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Test de l'installation des scripts Lambda Runtime Checker ===${NC}"
echo ""

# Test 1: Vérifier les dépendances
echo -e "${BLUE}1. Vérification des dépendances...${NC}"

if command -v aws &> /dev/null; then
    echo -e "${GREEN}✅ AWS CLI installé: $(aws --version)${NC}"
else
    echo -e "${RED}❌ AWS CLI non installé${NC}"
    exit 1
fi

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✅ jq installé: $(jq --version)${NC}"
else
    echo -e "${RED}❌ jq non installé${NC}"
    echo -e "${YELLOW}Installation: brew install jq${NC}"
    exit 1
fi

echo ""

# Test 2: Vérifier les profils AWS
echo -e "${BLUE}2. Vérification des profils AWS...${NC}"

if aws configure list-profiles &> /dev/null; then
    profiles=$(aws configure list-profiles)
    echo -e "${GREEN}✅ Profils AWS détectés:${NC}"
    echo "$profiles" | sed 's/^/  - /'
else
    echo -e "${RED}❌ Aucun profil AWS configuré${NC}"
    echo -e "${YELLOW}Configurez vos profils avec: aws configure --profile <nom-profil>${NC}"
    exit 1
fi

echo ""

# Test 3: Vérifier le script
echo -e "${BLUE}3. Vérification du script...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

script="check-lambda-runtimes.sh"

if [[ -f "$SCRIPT_DIR/$script" && -x "$SCRIPT_DIR/$script" ]]; then
    echo -e "${GREEN}✅ $script (exécutable)${NC}"
elif [[ -f "$SCRIPT_DIR/$script" ]]; then
    echo -e "${YELLOW}⚠️  $script (non exécutable)${NC}"
    chmod +x "$SCRIPT_DIR/$script"
    echo -e "${GREEN}✅ Permissions corrigées${NC}"
else
    echo -e "${RED}❌ $script manquant${NC}"
    exit 1
fi

echo ""

# Test 4: Test de connectivité AWS
echo -e "${BLUE}4. Test de connectivité AWS...${NC}"

# Tester avec le premier profil disponible
first_profile=$(aws configure list-profiles | head -n 2)

if [[ -n "$first_profile" ]]; then
    echo -e "${BLUE}Test avec le profil: $first_profile${NC}"
    
    if aws sts get-caller-identity --profile "$first_profile" &> /dev/null; then
        account_id=$(aws sts get-caller-identity --profile "$first_profile" --query 'Account' --output text)
        echo -e "${GREEN}✅ Connexion réussie - Compte: $account_id${NC}"
    else
        echo -e "${YELLOW}⚠️  Impossible de se connecter avec le profil $first_profile${NC}"
        echo -e "${YELLOW}Vérifiez vos credentials AWS${NC}"
    fi
else
    echo -e "${RED}❌ Aucun profil disponible pour le test${NC}"
fi

echo ""

# Test 5: Test du script avec --help
echo -e "${BLUE}5. Test du script (aide)...${NC}"

if "$SCRIPT_DIR/check-lambda-runtimes.sh" --help &> /dev/null; then
    echo -e "${GREEN}✅ check-lambda-runtimes.sh --help fonctionne${NC}"
else
    echo -e "${RED}❌ check-lambda-runtimes.sh --help échoue${NC}"
fi

echo ""

# Test 6: Vérifier la structure des dossiers
echo -e "${BLUE}6. Vérification de la structure...${NC}"

if [[ -f "$SCRIPT_DIR/README.md" ]]; then
    echo -e "${GREEN}✅ Documentation README.md présente${NC}"
else
    echo -e "${YELLOW}⚠️  README.md manquant${NC}"
fi

if [[ -d "$SCRIPT_DIR/reports" ]]; then
    echo -e "${GREEN}✅ Dossier reports/ existe${NC}"
else
    echo -e "${BLUE}ℹ️  Dossier reports/ sera créé automatiquement${NC}"
fi

echo ""

# Résumé et instructions
echo -e "${GREEN}=== Installation vérifiée avec succès! ===${NC}"
echo ""
echo -e "${BLUE}Prochaines étapes:${NC}"
echo -e "${YELLOW}1. Scanner vos fonctions Lambda Python:${NC}"
echo "   ./check-lambda-runtimes.sh python"
echo ""
echo -e "${YELLOW}2. Scanner vos fonctions Lambda Node.js:${NC}"
echo "   ./check-lambda-runtimes.sh nodejs"
echo ""
echo -e "${YELLOW}3. Scanner tous les runtimes obsolètes:${NC}"
echo "   ./check-lambda-runtimes.sh all"
echo ""
echo -e "${YELLOW}4. Consulter les rapports générés:${NC}"
echo "   ls -la reports/"
echo ""
echo -e "${GREEN}📚 Consultez le README.md pour plus d'informations${NC}"

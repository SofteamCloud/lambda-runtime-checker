#!/bin/bash

# AWS Lambda Runtime Checker
# Copyright (c) 2024 Softeam
# Licensed under the MIT License - see LICENSE file for details
#
# Script pour identifier les fonctions Lambda avec des runtimes obsolètes
# Usage: ./check-lambda-runtimes.sh [python|nodejs|all]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Profils à ignorer (utilisés uniquement pour SSO ou autres usages non-Lambda)
IGNORED_PROFILES=(
    "login"
)

# Régions à traiter (basées sur les régions gouvernées de l'organisation)
regions=(
    "eu-north-1"      # Europe (Stockholm)
    "eu-west-3"       # Europe (Paris)
    "us-east-2"       # US East (Ohio)
    "eu-west-1"       # Europe (Ireland)
    "eu-central-1"    # Europe (Frankfurt)
    "us-east-1"       # US East (N. Virginia)
    "us-west-2"       # US West (Oregon)
)

# Fonction pour obtenir le statut d'un runtime obsolète
get_runtime_status() {
    local runtime="$1"
    
    case "$runtime" in
        "python3.8")
            echo "EOL - Upgrade to python3.12 or python3.13"
            ;;
        "python3.9")
            echo "EOL December 15, 2025 - Upgrade to python3.12 or python3.13"
            ;;
        "nodejs16.x")
            echo "EOL - Upgrade to nodejs20.x or nodejs22.x"
            ;;
        "nodejs18.x")
            echo "EOL April 30, 2025 - Upgrade to nodejs20.x or nodejs22.x"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Fonction pour vérifier si un runtime est obsolète
is_runtime_obsolete() {
    local runtime="$1"
    local status
    status=$(get_runtime_status "$runtime")
    [[ -n "$status" ]]
}

# Couleurs pour l'affichage
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'aide
show_help() {
    cat << EOF
Usage: $0 [OPTION]

Options:
    python      Rechercher uniquement les runtimes Python obsolètes
    nodejs      Rechercher uniquement les runtimes Node.js obsolètes
    all         Rechercher tous les runtimes obsolètes (défaut)
    -h, --help  Afficher cette aide

Exemples:
    $0              # Rechercher tous les runtimes obsolètes
    $0 python       # Rechercher uniquement Python
    $0 nodejs       # Rechercher uniquement Node.js

Le script génère un rapport dans le dossier reports/ avec les détails des fonctions trouvées.

Note: Certains profils sont automatiquement ignorés (configurés dans IGNORED_PROFILES).
Actuellement ignorés: ${IGNORED_PROFILES[*]}

Runtimes obsolètes surveillés:
    Python:
    - python3.8: EOL - Upgrade to python3.12 or python3.13
    - python3.9: EOL December 15, 2025 - Upgrade to python3.12 or python3.13
    
    Node.js:
    - nodejs16.x: EOL - Upgrade to nodejs20.x or nodejs22.x
    - nodejs18.x: EOL April 30, 2025 - Upgrade to nodejs20.x or nodejs22.x
EOF
}

# Fonction pour créer le répertoire de sortie
create_output_dir() {
    mkdir -p "$OUTPUT_DIR"
    echo -e "${GREEN}Répertoire de sortie créé: $OUTPUT_DIR${NC}"
}

# Fonction pour obtenir la liste des profils AWS
get_aws_profiles() {
    aws configure list-profiles 2>/dev/null || {
        echo -e "${RED}Erreur: Impossible de lister les profils AWS${NC}"
        echo "Vérifiez que AWS CLI est installé et configuré"
        exit 1
    }
}

# Fonction pour vérifier si un profil doit être ignoré
should_ignore_profile() {
    local profile="$1"
    local ignored_profile
    
    for ignored_profile in "${IGNORED_PROFILES[@]}"; do
        if [[ "$profile" == "$ignored_profile" ]]; then
            return 0  # true - ignorer ce profil
        fi
    done
    
    return 1  # false - ne pas ignorer ce profil
}

# Fonction pour vérifier si un runtime correspond au filtre
runtime_matches_filter() {
    local runtime="$1"
    local filter="$2"
    
    case "$filter" in
        "python")
            [[ "$runtime" == python* ]]
            ;;
        "nodejs")
            [[ "$runtime" == nodejs* ]]
            ;;
        "all")
            true
            ;;
        *)
            false
            ;;
    esac
}

# Fonction pour scanner les fonctions Lambda
scan_lambda_functions() {
    local profile="$1"
    local region="$2"
    local filter="$3"
    local output_file="$4"
    
    echo -e "${BLUE}Scanning profile: $profile, region: $region${NC}"
    
    # Vérifier si le profil existe et est accessible
    if ! aws sts get-caller-identity --profile "$profile" --region "$region" &>/dev/null; then
        echo -e "${YELLOW}⚠️  Profil $profile inaccessible dans la région $region${NC}"
        return 0
    fi
    
    # Obtenir l'ID du compte
    local account_id
    account_id=$(aws sts get-caller-identity --profile "$profile" --region "$region" --query 'Account' --output text 2>/dev/null || echo "Unknown")
    
    # Lister toutes les fonctions Lambda
    local functions
    functions=$(aws lambda list-functions \
        --profile "$profile" \
        --region "$region" \
        --output json 2>/dev/null || echo '{"Functions":[]}')
    
    # Traiter chaque fonction
    echo "$functions" | jq -r '.Functions[] | @base64' | while IFS= read -r function_data; do
        local function_info
        function_info=$(echo "$function_data" | base64 --decode)
        
        local function_name runtime function_arn last_modified
        function_name=$(echo "$function_info" | jq -r '.FunctionName')
        runtime=$(echo "$function_info" | jq -r '.Runtime')
        function_arn=$(echo "$function_info" | jq -r '.FunctionArn')
        last_modified=$(echo "$function_info" | jq -r '.LastModified')
        
        # Vérifier si le runtime correspond au filtre et est obsolète
        if runtime_matches_filter "$runtime" "$filter" && is_runtime_obsolete "$runtime"; then
            local status
            status=$(get_runtime_status "$runtime")
            
            # Écrire dans le fichier de sortie
            {
                echo "FUNCTION_FOUND"
                echo "Account: $account_id"
                echo "Profile: $profile"
                echo "Region: $region"
                echo "Function: $function_name"
                echo "Runtime: $runtime"
                echo "Status: $status"
                echo "ARN: $function_arn"
                echo "Last Modified: $last_modified"
                echo "---"
            } >> "$output_file"
            
            echo -e "${RED}🔍 Trouvé: $function_name ($runtime) - $status${NC}"
        fi
    done
}

# Fonction principale
main() {
    local filter="${1:-all}"
    
    # Vérifier les paramètres
    case "$filter" in
        "-h"|"--help")
            show_help
            exit 0
            ;;
        "python"|"nodejs"|"all")
            ;;
        *)
            echo -e "${RED}Erreur: Paramètre invalide '$filter'${NC}"
            show_help
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}=== Scan des fonctions Lambda avec runtimes obsolètes ===${NC}"
    echo -e "${BLUE}Filtre: $filter${NC}"
    echo -e "${BLUE}Timestamp: $TIMESTAMP${NC}"
    echo ""
    
    # Créer le répertoire de sortie
    create_output_dir
    
    # Fichiers de sortie
    local detailed_report="$OUTPUT_DIR/lambda_obsolete_runtimes_${filter}_${TIMESTAMP}.txt"
    local csv_report="$OUTPUT_DIR/lambda_obsolete_runtimes_${filter}_${TIMESTAMP}.csv"
    local summary_report="$OUTPUT_DIR/summary_${filter}_${TIMESTAMP}.txt"
    
    # Initialiser les fichiers de rapport
    {
        echo "# Rapport des fonctions Lambda avec runtimes obsolètes"
        echo "# Généré le: $(date)"
        echo "# Filtre appliqué: $filter"
        echo "# Régions scannées: ${regions[*]}"
        echo ""
    } > "$detailed_report"
    
    {
        echo "Account,Profile,Region,Function,Runtime,Status,ARN,LastModified"
    } > "$csv_report"
    
    # Obtenir la liste des profils
    local profiles
    profiles=$(get_aws_profiles)
    
    if [[ -z "$profiles" ]]; then
        echo -e "${RED}Aucun profil AWS trouvé${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Profils AWS détectés:${NC}"
    echo "$profiles" | sed 's/^/  - /'
    echo ""
    
    # Variables pour le résumé
    local total_functions=0
    local total_accounts=0
    local account_functions=0
    
    # Scanner chaque profil et région
    while IFS= read -r profile; do
        [[ -z "$profile" ]] && continue
        
        # Vérifier si le profil doit être ignoré
        if should_ignore_profile "$profile"; then
            echo -e "${YELLOW}⏭️  Profil '$profile' ignoré (configuré comme profil à ignorer)${NC}"
            continue
        fi
        
        echo -e "${GREEN}=== Scanning profile: $profile ===${NC}"
        account_functions=0
        
        for region in "${regions[@]}"; do
            local temp_file=$(mktemp)
            scan_lambda_functions "$profile" "$region" "$filter" "$temp_file"
            
            # Compter les fonctions trouvées et les ajouter aux rapports
            local region_functions=0
            while IFS= read -r line; do
                if [[ "$line" == "FUNCTION_FOUND" ]]; then
                    ((region_functions++))
                    ((account_functions++))
                    ((total_functions++))
                    
                    # Lire les détails de la fonction
                    local account profile_name region_name function_name runtime status arn last_modified
                    read -r account
                    read -r profile_name
                    read -r region_name
                    read -r function_name
                    read -r runtime
                    read -r status
                    read -r arn
                    read -r last_modified
                    
                    # Nettoyer les valeurs
                    account=${account#"Account: "}
                    profile_name=${profile_name#"Profile: "}
                    region_name=${region_name#"Region: "}
                    function_name=${function_name#"Function: "}
                    runtime=${runtime#"Runtime: "}
                    status=${status#"Status: "}
                    arn=${arn#"ARN: "}
                    last_modified=${last_modified#"Last Modified: "}
                    
                    # Ajouter au rapport détaillé
                    {
                        echo "Account: $account"
                        echo "Profile: $profile_name"
                        echo "Region: $region_name"
                        echo "Function: $function_name"
                        echo "Runtime: $runtime"
                        echo "Status: $status"
                        echo "ARN: $arn"
                        echo "Last Modified: $last_modified"
                        echo ""
                    } >> "$detailed_report"
                    
                    # Ajouter au CSV
                    echo "\"$account\",\"$profile_name\",\"$region_name\",\"$function_name\",\"$runtime\",\"$status\",\"$arn\",\"$last_modified\"" >> "$csv_report"
                fi
            done < "$temp_file"
            
            rm -f "$temp_file"
        done
        
        if [[ $account_functions -gt 0 ]]; then
            ((total_accounts++))
        fi
        
        echo ""
    done <<< "$profiles"
    
    # Générer le résumé
    {
        echo "=== RÉSUMÉ DU SCAN ==="
        echo "Date: $(date)"
        echo "Filtre appliqué: $filter"
        echo "Régions scannées: ${regions[*]}"
        echo "Profils ignorés: ${IGNORED_PROFILES[*]}"
        echo ""
        echo "RÉSULTATS:"
        echo "- Total des fonctions avec runtimes obsolètes: $total_functions"
        echo "- Nombre de comptes impactés: $total_accounts"
        echo ""
        
        echo "RUNTIMES OBSOLÈTES RECHERCHÉS:"
        if [[ "$filter" == "python" || "$filter" == "all" ]]; then
            echo "- python3.8: $(get_runtime_status "python3.8")"
            echo "- python3.9: $(get_runtime_status "python3.9")"
        fi
        if [[ "$filter" == "nodejs" || "$filter" == "all" ]]; then
            echo "- nodejs16.x: $(get_runtime_status "nodejs16.x")"
            echo "- nodejs18.x: $(get_runtime_status "nodejs18.x")"
        fi
        echo ""
        
        echo "FICHIERS GÉNÉRÉS:"
        echo "- Rapport détaillé: $detailed_report"
        echo "- Rapport CSV: $csv_report"
        echo "- Résumé: $summary_report"
    } > "$summary_report"
    
    # Afficher le résumé
    echo -e "${GREEN}=== RÉSUMÉ FINAL ===${NC}"
    cat "$summary_report"
    
    if [[ $total_functions -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $total_functions fonction(s) Lambda avec des runtimes obsolètes trouvée(s)${NC}"
        echo -e "${BLUE}📋 Consultez les rapports dans: $OUTPUT_DIR${NC}"
    else
        echo -e "${GREEN}✅ Aucune fonction Lambda avec runtime obsolète trouvée${NC}"
    fi
}

# Vérifier les dépendances
check_dependencies() {
    local missing_deps=()
    
    if ! command -v aws &> /dev/null; then
        missing_deps+=("aws-cli")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}Erreur: Dépendances manquantes: ${missing_deps[*]}${NC}"
        echo "Installez les dépendances manquantes:"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                "aws-cli")
                    echo "  - AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
                    ;;
                "jq")
                    echo "  - jq: brew install jq (macOS) ou apt-get install jq (Ubuntu)"
                    ;;
            esac
        done
        exit 1
    fi
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_dependencies
    main "$@"
fi

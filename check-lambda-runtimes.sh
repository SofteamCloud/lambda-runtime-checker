#!/bin/bash

# AWS Lambda Runtime Checker
# Copyright (c) 2024 Softeam
# Licensed under the MIT License - see LICENSE file for details
#
# Script to identify Lambda functions with obsolete runtimes
# Usage: ./check-lambda-runtimes.sh [python|nodejs|all]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Profiles to ignore (used only for SSO or other non-Lambda purposes)
IGNORED_PROFILES=(
    "login"
)

# Regions to process (based on organization's governed regions)
regions=(
    "eu-north-1"      # Europe (Stockholm)
    "eu-west-3"       # Europe (Paris)
    "us-east-2"       # US East (Ohio)
    "eu-west-1"       # Europe (Ireland)
    "eu-central-1"    # Europe (Frankfurt)
    "us-east-1"       # US East (N. Virginia)
    "us-west-2"       # US West (Oregon)
)

# Function to get obsolete runtime status
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

# Function to check if a runtime is obsolete
is_runtime_obsolete() {
    local runtime="$1"
    local status
    status=$(get_runtime_status "$runtime")
    [[ -n "$status" ]]
}

# Colors for display
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    cat << EOF
Usage: $0 [OPTION]

Options:
    python      Search only for obsolete Python runtimes
    nodejs      Search only for obsolete Node.js runtimes
    all         Search for all obsolete runtimes (default)
    -h, --help  Show this help

Examples:
    $0              # Search for all obsolete runtimes
    $0 python       # Search only for Python
    $0 nodejs       # Search only for Node.js

The script generates a report in the reports/ folder with details of found functions.

Note: Some profiles are automatically ignored (configured in IGNORED_PROFILES).
Currently ignored: ${IGNORED_PROFILES[*]}

Monitored obsolete runtimes:
    Python:
    - python3.8: EOL - Upgrade to python3.12 or python3.13
    - python3.9: EOL December 15, 2025 - Upgrade to python3.12 or python3.13
    
    Node.js:
    - nodejs16.x: EOL - Upgrade to nodejs20.x or nodejs22.x
    - nodejs18.x: EOL April 30, 2025 - Upgrade to nodejs20.x or nodejs22.x
EOF
}

# Function to create output directory
create_output_dir() {
    mkdir -p "$OUTPUT_DIR"
    echo -e "${GREEN}Output directory created: $OUTPUT_DIR${NC}"
}

# Function to get AWS profiles list
get_aws_profiles() {
    aws configure list-profiles 2>/dev/null || {
        echo -e "${RED}Error: Unable to list AWS profiles${NC}"
        echo "Check that AWS CLI is installed and configured"
        exit 1
    }
}

# Function to check if a profile should be ignored
should_ignore_profile() {
    local profile="$1"
    local ignored_profile
    
    for ignored_profile in "${IGNORED_PROFILES[@]}"; do
        if [[ "$profile" == "$ignored_profile" ]]; then
            return 0  # true - ignore this profile
        fi
    done
    
    return 1  # false - do not ignore this profile
}

# Function to check if a runtime matches the filter
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

# Function to scan Lambda functions
scan_lambda_functions() {
    local profile="$1"
    local region="$2"
    local filter="$3"
    local output_file="$4"
    
    echo -e "${BLUE}Scanning profile: $profile, region: $region${NC}"
    
    # Check if profile exists and is accessible
    if ! aws sts get-caller-identity --profile "$profile" --region "$region" &>/dev/null; then
        echo -e "${YELLOW}⚠️  Profile $profile inaccessible in region $region${NC}"
        return 0
    fi
    
    # Get account ID
    local account_id
    account_id=$(aws sts get-caller-identity --profile "$profile" --region "$region" --query 'Account' --output text 2>/dev/null || echo "Unknown")
    
    # List all Lambda functions
    local functions
    functions=$(aws lambda list-functions \
        --profile "$profile" \
        --region "$region" \
        --output json 2>/dev/null || echo '{"Functions":[]}')
    
    # Process each function
    echo "$functions" | jq -r '.Functions[] | @base64' | while IFS= read -r function_data; do
        local function_info
        function_info=$(echo "$function_data" | base64 --decode)
        
        local function_name runtime function_arn last_modified
        function_name=$(echo "$function_info" | jq -r '.FunctionName')
        runtime=$(echo "$function_info" | jq -r '.Runtime')
        function_arn=$(echo "$function_info" | jq -r '.FunctionArn')
        last_modified=$(echo "$function_info" | jq -r '.LastModified')
        
        # Check if runtime matches filter and is obsolete
        if runtime_matches_filter "$runtime" "$filter" && is_runtime_obsolete "$runtime"; then
            local status
            status=$(get_runtime_status "$runtime")
            
            # Write to output file
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
            
            echo -e "${RED}🔍 Found: $function_name ($runtime) - $status${NC}"
        fi
    done
}

# Main function
main() {
    local filter="${1:-all}"
    
    # Check parameters
    case "$filter" in
        "-h"|"--help")
            show_help
            exit 0
            ;;
        "python"|"nodejs"|"all")
            ;;
        *)
            echo -e "${RED}Error: Invalid parameter '$filter'${NC}"
            show_help
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}=== Lambda Functions Scan for Obsolete Runtimes ===${NC}"
    echo -e "${BLUE}Filter: $filter${NC}"
    echo -e "${BLUE}Timestamp: $TIMESTAMP${NC}"
    echo ""
    
    # Create output directory
    create_output_dir
    
    # Output files
    local detailed_report="$OUTPUT_DIR/lambda_obsolete_runtimes_${filter}_${TIMESTAMP}.txt"
    local csv_report="$OUTPUT_DIR/lambda_obsolete_runtimes_${filter}_${TIMESTAMP}.csv"
    local summary_report="$OUTPUT_DIR/summary_${filter}_${TIMESTAMP}.txt"
    
    # Initialize report files
    {
        echo "# Lambda Functions Report with Obsolete Runtimes"
        echo "# Generated on: $(date)"
        echo "# Applied filter: $filter"
        echo "# Scanned regions: ${regions[*]}"
        echo ""
    } > "$detailed_report"
    
    {
        echo "Account,Profile,Region,Function,Runtime,Status,ARN,LastModified"
    } > "$csv_report"
    
    # Get profiles list
    local profiles
    profiles=$(get_aws_profiles)
    
    if [[ -z "$profiles" ]]; then
        echo -e "${RED}No AWS profiles found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Detected AWS profiles:${NC}"
    echo "$profiles" | sed 's/^/  - /'
    echo ""
    
    # Variables for summary
    local total_functions=0
    local total_accounts=0
    local account_functions=0
    
    # Scan each profile and region
    while IFS= read -r profile; do
        [[ -z "$profile" ]] && continue
        
        # Check if profile should be ignored
        if should_ignore_profile "$profile"; then
            echo -e "${YELLOW}⏭️  Profile '$profile' ignored (configured as profile to ignore)${NC}"
            continue
        fi
        
        echo -e "${GREEN}=== Scanning profile: $profile ===${NC}"
        account_functions=0
        
        for region in "${regions[@]}"; do
            local temp_file=$(mktemp)
            scan_lambda_functions "$profile" "$region" "$filter" "$temp_file"
            
            # Count found functions and add to reports
            local region_functions=0
            while IFS= read -r line; do
                if [[ "$line" == "FUNCTION_FOUND" ]]; then
                    ((region_functions++))
                    ((account_functions++))
                    ((total_functions++))
                    
                    # Read function details
                    local account profile_name region_name function_name runtime status arn last_modified
                    read -r account
                    read -r profile_name
                    read -r region_name
                    read -r function_name
                    read -r runtime
                    read -r status
                    read -r arn
                    read -r last_modified
                    
                    # Clean values
                    account=${account#"Account: "}
                    profile_name=${profile_name#"Profile: "}
                    region_name=${region_name#"Region: "}
                    function_name=${function_name#"Function: "}
                    runtime=${runtime#"Runtime: "}
                    status=${status#"Status: "}
                    arn=${arn#"ARN: "}
                    last_modified=${last_modified#"Last Modified: "}
                    
                    # Add to detailed report
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
                    
                    # Add to CSV
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
    
    # Generate summary
    {
        echo "=== SCAN SUMMARY ==="
        echo "Date: $(date)"
        echo "Applied filter: $filter"
        echo "Scanned regions: ${regions[*]}"
        echo "Ignored profiles: ${IGNORED_PROFILES[*]}"
        echo ""
        echo "RESULTS:"
        echo "- Total functions with obsolete runtimes: $total_functions"
        echo "- Number of impacted accounts: $total_accounts"
        echo ""
        
        echo "SEARCHED OBSOLETE RUNTIMES:"
        if [[ "$filter" == "python" || "$filter" == "all" ]]; then
            echo "- python3.8: $(get_runtime_status "python3.8")"
            echo "- python3.9: $(get_runtime_status "python3.9")"
        fi
        if [[ "$filter" == "nodejs" || "$filter" == "all" ]]; then
            echo "- nodejs16.x: $(get_runtime_status "nodejs16.x")"
            echo "- nodejs18.x: $(get_runtime_status "nodejs18.x")"
        fi
        echo ""
        
        echo "GENERATED FILES:"
        echo "- Detailed report: $detailed_report"
        echo "- CSV report: $csv_report"
        echo "- Summary: $summary_report"
    } > "$summary_report"
    
    # Display summary
    echo -e "${GREEN}=== FINAL SUMMARY ===${NC}"
    cat "$summary_report"
    
    if [[ $total_functions -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $total_functions Lambda function(s) with obsolete runtimes found${NC}"
        echo -e "${BLUE}📋 Check reports in: $OUTPUT_DIR${NC}"
    else
        echo -e "${GREEN}✅ No Lambda functions with obsolete runtimes found${NC}"
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v aws &> /dev/null; then
        missing_deps+=("aws-cli")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing dependencies: ${missing_deps[*]}${NC}"
        echo "Install missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                "aws-cli")
                    echo "  - AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
                    ;;
                "jq")
                    echo "  - jq: brew install jq (macOS) or apt-get install jq (Ubuntu)"
                    ;;
            esac
        done
        exit 1
    fi
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_dependencies
    main "$@"
fi

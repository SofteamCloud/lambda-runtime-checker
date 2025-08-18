#!/bin/bash

# AWS Lambda Runtime Checker - Test Setup
# Copyright (c) 2024 Softeam
# Licensed under the MIT License - see LICENSE file for details
#
# Test script to verify installation and configuration
# Usage: ./test-setup.sh

set -euo pipefail

# Colors for display
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== AWS Lambda Runtime Checker Installation Test ===${NC}"
echo ""

# Test 1: Check dependencies
echo -e "${BLUE}1. Checking dependencies...${NC}"

if command -v aws &> /dev/null; then
    echo -e "${GREEN}✅ AWS CLI installed: $(aws --version)${NC}"
else
    echo -e "${RED}❌ AWS CLI not installed${NC}"
    exit 1
fi

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✅ jq installed: $(jq --version)${NC}"
else
    echo -e "${RED}❌ jq not installed${NC}"
    echo -e "${YELLOW}Installation: brew install jq${NC}"
    exit 1
fi

echo ""

# Test 2: Check AWS profiles
echo -e "${BLUE}2. Checking AWS profiles...${NC}"

if aws configure list-profiles &> /dev/null; then
    profiles=$(aws configure list-profiles)
    echo -e "${GREEN}✅ AWS profiles detected:${NC}"
    echo "$profiles" | sed 's/^/  - /'
else
    echo -e "${RED}❌ No AWS profiles configured${NC}"
    echo -e "${YELLOW}Configure your profiles with: aws configure --profile <profile-name>${NC}"
    exit 1
fi

echo ""

# Test 3: Check script
echo -e "${BLUE}3. Checking script...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

script="check-lambda-runtimes.sh"

if [[ -f "$SCRIPT_DIR/$script" && -x "$SCRIPT_DIR/$script" ]]; then
    echo -e "${GREEN}✅ $script (executable)${NC}"
elif [[ -f "$SCRIPT_DIR/$script" ]]; then
    echo -e "${YELLOW}⚠️  $script (not executable)${NC}"
    chmod +x "$SCRIPT_DIR/$script"
    echo -e "${GREEN}✅ Permissions fixed${NC}"
else
    echo -e "${RED}❌ $script missing${NC}"
    exit 1
fi

echo ""

# Test 4: Test AWS connectivity
echo -e "${BLUE}4. Testing AWS connectivity...${NC}"

# Test with first available profile
first_profile=$(aws configure list-profiles | head -n 1)

if [[ -n "$first_profile" ]]; then
    echo -e "${BLUE}Testing with profile: $first_profile${NC}"
    
    if aws sts get-caller-identity --profile "$first_profile" &> /dev/null; then
        account_id=$(aws sts get-caller-identity --profile "$first_profile" --query 'Account' --output text)
        echo -e "${GREEN}✅ Connection successful - Account: $account_id${NC}"
    else
        echo -e "${YELLOW}⚠️  Unable to connect with profile $first_profile${NC}"
        echo -e "${YELLOW}Check your AWS credentials${NC}"
    fi
else
    echo -e "${RED}❌ No profile available for testing${NC}"
fi

echo ""

# Test 5: Test script with --help
echo -e "${BLUE}5. Testing script (help)...${NC}"

if "$SCRIPT_DIR/check-lambda-runtimes.sh" --help &> /dev/null; then
    echo -e "${GREEN}✅ check-lambda-runtimes.sh --help works${NC}"
else
    echo -e "${RED}❌ check-lambda-runtimes.sh --help fails${NC}"
fi

echo ""

# Test 6: Check structure
echo -e "${BLUE}6. Checking structure...${NC}"

if [[ -f "$SCRIPT_DIR/README.md" ]]; then
    echo -e "${GREEN}✅ README.md documentation present${NC}"
else
    echo -e "${YELLOW}⚠️  README.md missing${NC}"
fi

if [[ -d "$SCRIPT_DIR/reports" ]]; then
    echo -e "${GREEN}✅ reports/ folder exists${NC}"
else
    echo -e "${BLUE}ℹ️  reports/ folder will be created automatically${NC}"
fi

echo ""

# Summary and instructions
echo -e "${GREEN}=== Installation verified successfully! ===${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}1. Scan your Python Lambda functions:${NC}"
echo "   ./check-lambda-runtimes.sh python"
echo ""
echo -e "${YELLOW}2. Scan your Node.js Lambda functions:${NC}"
echo "   ./check-lambda-runtimes.sh nodejs"
echo ""
echo -e "${YELLOW}3. Scan all obsolete runtimes:${NC}"
echo "   ./check-lambda-runtimes.sh all"
echo ""
echo -e "${YELLOW}4. Check generated reports:${NC}"
echo "   ls -la reports/"
echo ""
echo -e "${GREEN}📚 Check README.md for more information${NC}"

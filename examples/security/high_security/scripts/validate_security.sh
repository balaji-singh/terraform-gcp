#!/bin/bash

# Validation script for high-security configuration
# This script verifies that all required security controls are in place

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse command line arguments
while getopts "p:e:" opt; do
  case $opt in
    p) PROJECT_ID="$OPTARG";;
    e) ENVIRONMENT="$OPTARG";;
    *) echo "Usage: $0 -p PROJECT_ID -e ENVIRONMENT" >&2; exit 1;;
  esac
done

# Verify required arguments
if [ -z "$PROJECT_ID" ] || [ -z "$ENVIRONMENT" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 -p PROJECT_ID -e ENVIRONMENT"
  exit 1
fi

# Function to check if an API is enabled
check_api_enabled() {
  local api=$1
  if gcloud services list --project="$PROJECT_ID" --filter="config.name:$api" --format="get(config.name)" | grep -q "^$api$"; then
    echo -e "${GREEN}✓ $api is enabled${NC}"
    return 0
  else
    echo -e "${RED}✗ $api is not enabled${NC}"
    return 1
  fi
}

# Function to check if a security control is enabled
check_security_control() {
  local control=$1
  local command=$2
  local expected=$3
  
  if eval "$command" | grep -q "$expected"; then
    echo -e "${GREEN}✓ $control is properly configured${NC}"
    return 0
  else
    echo -e "${RED}✗ $control is not properly configured${NC}"
    return 1
  fi
}

# Main validation function
validate_security_configuration() {
  local errors=0

  echo "Validating security configuration for project $PROJECT_ID in $ENVIRONMENT environment..."

  # Check required APIs
  echo -e "\nChecking required APIs..."
  local required_apis=(
    "cloudkms.googleapis.com"
    "secretmanager.googleapis.com"
    "binaryauthorization.googleapis.com"
    "containeranalysis.googleapis.com"
    "cloudasset.googleapis.com"
    "securitycenter.googleapis.com"
  )

  for api in "${required_apis[@]}"; do
    check_api_enabled "$api" || ((errors++))
  done

  # Check VPC Service Controls
  echo -e "\nChecking VPC Service Controls..."
  if gcloud access-context-manager perimeters list --organization="$ORG_ID" --format="get(name)" | grep -q "high-security-perimeter"; then
    echo -e "${GREEN}✓ VPC Service Controls are configured${NC}"
  else
    echo -e "${RED}✗ VPC Service Controls are not configured${NC}"
    ((errors++))
  fi

  # Check Binary Authorization
  echo -e "\nChecking Binary Authorization..."
  if gcloud container binauthz policy import --project="$PROJECT_ID" - <<< "" 2>&1 | grep -q "evaluation_mode.*=.*REQUIRE_ATTESTATION"; then
    echo -e "${GREEN}✓ Binary Authorization is properly configured${NC}"
  else
    echo -e "${RED}✗ Binary Authorization is not properly configured${NC}"
    ((errors++))
  fi

  # Check Audit Logging
  echo -e "\nChecking Audit Logging..."
  if gcloud logging sinks list --project="$PROJECT_ID" --format="get(name)" | grep -q "all-audit-logs"; then
    echo -e "${GREEN}✓ Audit logging is configured${NC}"
  else
    echo -e "${RED}✗ Audit logging is not configured${NC}"
    ((errors++))
  fi

  # Check KMS Configuration
  echo -e "\nChecking KMS Configuration..."
  if gcloud kms keys list --project="$PROJECT_ID" --location="global" --keyring="high-security-keyring" --format="get(name)" | grep -q "data-encryption-key"; then
    echo -e "${GREEN}✓ KMS is properly configured${NC}"
  else
    echo -e "${RED}✗ KMS is not properly configured${NC}"
    ((errors++))
  fi

  # Check Security Command Center
  echo -e "\nChecking Security Command Center..."
  if gcloud scc notifications list --organization="$ORG_ID" --format="get(name)" | grep -q "critical-alerts"; then
    echo -e "${GREEN}✓ Security Command Center notifications are configured${NC}"
  else
    echo -e "${RED}✗ Security Command Center notifications are not configured${NC}"
    ((errors++))
  fi

  # Check IAM Policies
  echo -e "\nChecking IAM Policies..."
  if gcloud projects get-iam-policy "$PROJECT_ID" --format="get(bindings.role)" | grep -q "roles/restricted_viewer"; then
    echo -e "${GREEN}✓ Custom IAM roles are configured${NC}"
  else
    echo -e "${RED}✗ Custom IAM roles are not configured${NC}"
    ((errors++))
  fi

  # Check Asset Inventory
  echo -e "\nChecking Asset Inventory..."
  if gcloud asset feeds list --project="$PROJECT_ID" --format="get(name)" | grep -q "asset-feed"; then
    echo -e "${GREEN}✓ Asset Inventory feed is configured${NC}"
  else
    echo -e "${RED}✗ Asset Inventory feed is not configured${NC}"
    ((errors++))
  fi

  # Check Security Scanner
  echo -e "\nChecking Security Scanner..."
  if gcloud web-security-scanner scan-configs list --project="$PROJECT_ID" --format="get(name)" | grep -q "enhanced-security-scan"; then
    echo -e "${GREEN}✓ Security Scanner is configured${NC}"
  else
    echo -e "${RED}✗ Security Scanner is not configured${NC}"
    ((errors++))
  fi

  # Final validation result
  echo -e "\nValidation completed with $errors error(s)"
  if [ $errors -eq 0 ]; then
    echo -e "${GREEN}All security controls are properly configured!${NC}"
    return 0
  else
    echo -e "${RED}Some security controls are missing or misconfigured. Please review and fix the issues.${NC}"
    return 1
  fi
}

# Execute validation
validate_security_configuration

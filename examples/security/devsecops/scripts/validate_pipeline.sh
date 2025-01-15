#!/bin/bash

# Validation script for DevSecOps pipeline security configuration
# This script verifies that all required security controls are in place

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse command line arguments
while getopts "p:e:r:" opt; do
  case $opt in
    p) PROJECT_ID="$OPTARG";;
    e) ENVIRONMENT="$OPTARG";;
    r) REPOSITORY="$OPTARG";;
    *) echo "Usage: $0 -p PROJECT_ID -e ENVIRONMENT -r REPOSITORY" >&2; exit 1;;
  esac
done

# Verify required arguments
if [ -z "$PROJECT_ID" ] || [ -z "$ENVIRONMENT" ] || [ -z "$REPOSITORY" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 -p PROJECT_ID -e ENVIRONMENT -r REPOSITORY"
  exit 1
fi

# Function to check Cloud Build trigger
check_build_trigger() {
  echo "Checking Cloud Build trigger..."
  if gcloud builds triggers list --project="$PROJECT_ID" --filter="name:secure-build" --format="get(name)" | grep -q "secure-build"; then
    echo -e "${GREEN}✓ Build trigger is configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Build trigger is not configured${NC}"
    return 1
  fi
}

# Function to check Binary Authorization
check_binary_authorization() {
  echo "Checking Binary Authorization..."
  if gcloud container binauthz policy import --project="$PROJECT_ID" - <<< "" 2>&1 | grep -q "evaluation_mode.*=.*REQUIRE_ATTESTATION"; then
    echo -e "${GREEN}✓ Binary Authorization is properly configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Binary Authorization is not properly configured${NC}"
    return 1
  fi
}

# Function to check Container Analysis
check_container_analysis() {
  echo "Checking Container Analysis..."
  if gcloud container analysis notes list --project="$PROJECT_ID" --filter="name:security-note" --format="get(name)" | grep -q "security-note"; then
    echo -e "${GREEN}✓ Container Analysis is configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Container Analysis is not configured${NC}"
    return 1
  fi
}

# Function to check Secret Manager
check_secret_manager() {
  echo "Checking Secret Manager..."
  if gcloud secrets list --project="$PROJECT_ID" --filter="name:pipeline-key" --format="get(name)" | grep -q "pipeline-key"; then
    echo -e "${GREEN}✓ Pipeline secrets are configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Pipeline secrets are not configured${NC}"
    return 1
  fi
}

# Function to check IAM configuration
check_iam_configuration() {
  echo "Checking IAM configuration..."
  if gcloud iam service-accounts list --project="$PROJECT_ID" --filter="email:pipeline-sa" --format="get(email)" | grep -q "pipeline-sa"; then
    echo -e "${GREEN}✓ Pipeline service account is configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Pipeline service account is not configured${NC}"
    return 1
  fi
}

# Function to check Security Scanner
check_security_scanner() {
  echo "Checking Security Scanner..."
  if gcloud web-security-scanner scan-configs list --project="$PROJECT_ID" --filter="displayName:artifact-scan" --format="get(name)" | grep -q "artifact-scan"; then
    echo -e "${GREEN}✓ Security Scanner is configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Security Scanner is not configured${NC}"
    return 1
  fi
}

# Function to check Audit Logging
check_audit_logging() {
  echo "Checking Audit Logging..."
  if gcloud logging sinks list --project="$PROJECT_ID" --format="get(name)" | grep -q "cloudbuild-logs"; then
    echo -e "${GREEN}✓ Audit logging is configured${NC}"
    return 0
  else
    echo -e "${RED}✗ Audit logging is not configured${NC}"
    return 1
  fi
}

# Function to check KMS configuration
check_kms_configuration() {
  echo "Checking KMS configuration..."
  if gcloud kms keys list --project="$PROJECT_ID" --location="global" --keyring="pipeline-keyring" --format="get(name)" | grep -q "artifact-signing-key"; then
    echo -e "${GREEN}✓ KMS is properly configured${NC}"
    return 0
  else
    echo -e "${RED}✗ KMS is not properly configured${NC}"
    return 1
  fi
}

# Function to validate container images
validate_container_images() {
  echo "Validating container images..."
  local image_path="gcr.io/$PROJECT_ID/secure-app"
  
  # Check if image exists
  if gcloud container images list-tags "$image_path" --format="get(tags)" 2>/dev/null | grep -q "latest"; then
    echo -e "${GREEN}✓ Container image exists${NC}"
    
    # Check vulnerability scanning
    if gcloud container images describe "$image_path:latest" --format="get(discovery.analysisStatus)" 2>/dev/null | grep -q "FINISHED"; then
      echo -e "${GREEN}✓ Vulnerability scanning completed${NC}"
    else
      echo -e "${RED}✗ Vulnerability scanning not completed${NC}"
      return 1
    fi
  else
    echo -e "${YELLOW}! Container image not found - this may be expected for new deployments${NC}"
  fi
  return 0
}

# Main validation function
main() {
  local errors=0
  
  echo "Starting DevSecOps pipeline validation for project $PROJECT_ID..."
  
  # Run all checks
  check_build_trigger || ((errors++))
  check_binary_authorization || ((errors++))
  check_container_analysis || ((errors++))
  check_secret_manager || ((errors++))
  check_iam_configuration || ((errors++))
  check_security_scanner || ((errors++))
  check_audit_logging || ((errors++))
  check_kms_configuration || ((errors++))
  validate_container_images || ((errors++))
  
  # Final validation result
  echo -e "\nValidation completed with $errors error(s)"
  if [ $errors -eq 0 ]; then
    echo -e "${GREEN}All pipeline security controls are properly configured!${NC}"
    return 0
  else
    echo -e "${RED}Some pipeline security controls are missing or misconfigured. Please review and fix the issues.${NC}"
    return 1
  fi
}

# Execute main function
main

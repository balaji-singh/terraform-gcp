#!/bin/bash

# Validation script for GCP Terraform configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Terraform formatting
check_terraform_fmt() {
    echo "Checking Terraform formatting..."
    if ! terraform fmt -check -recursive; then
        echo -e "${RED}Terraform formatting check failed. Run 'terraform fmt -recursive' to fix.${NC}"
        return 1
    fi
    echo -e "${GREEN}Terraform formatting check passed.${NC}"
}

# Validate Terraform configurations
validate_terraform() {
    echo "Validating Terraform configurations..."
    if ! terraform validate; then
        echo -e "${RED}Terraform validation failed.${NC}"
        return 1
    fi
    echo -e "${GREEN}Terraform validation passed.${NC}"
}

# Run tflint
run_tflint() {
    echo "Running tflint..."
    if ! command -v tflint &> /dev/null; then
        echo -e "${YELLOW}tflint not found. Skipping.${NC}"
        return 0
    fi
    if ! tflint; then
        echo -e "${RED}tflint check failed.${NC}"
        return 1
    fi
    echo -e "${GREEN}tflint check passed.${NC}"
}

# Run checkov
run_checkov() {
    echo "Running checkov..."
    if ! command -v checkov &> /dev/null; then
        echo -e "${YELLOW}checkov not found. Skipping.${NC}"
        return 0
    fi
    if ! checkov -d .; then
        echo -e "${RED}checkov check failed.${NC}"
        return 1
    fi
    echo -e "${GREEN}checkov check passed.${NC}"
}

# Run tfsec
run_tfsec() {
    echo "Running tfsec..."
    if ! command -v tfsec &> /dev/null; then
        echo -e "${YELLOW}tfsec not found. Skipping.${NC}"
        return 0
    fi
    if ! tfsec .; then
        echo -e "${RED}tfsec check failed.${NC}"
        return 1
    fi
    echo -e "${GREEN}tfsec check passed.${NC}"
}

# Validate GCP provider configuration
validate_gcp_config() {
    echo "Validating GCP configuration..."
    if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${RED}GOOGLE_APPLICATION_CREDENTIALS not set.${NC}"
        return 1
    fi
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" > /dev/null; then
        echo -e "${RED}No active GCP account found.${NC}"
        return 1
    fi
    echo -e "${GREEN}GCP configuration valid.${NC}"
}

# Check for required variables
check_required_vars() {
    echo "Checking required variables..."
    local required_vars=(
        "TF_VAR_project_id"
        "TF_VAR_region"
        "TF_VAR_environment"
    )
    local missing_vars=0
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo -e "${RED}Required variable $var is not set.${NC}"
            missing_vars=1
        fi
    done
    
    if [ $missing_vars -eq 1 ]; then
        return 1
    fi
    echo -e "${GREEN}All required variables are set.${NC}"
}

# Check module dependencies
check_module_dependencies() {
    echo "Checking module dependencies..."
    local modules=($(find . -type f -name "*.tf" -exec grep -l "module" {} \;))
    local missing_deps=0
    
    for module in "${modules[@]}"; do
        local dir=$(dirname "$module")
        if ! terraform init -backend=false "$dir" > /dev/null; then
            echo -e "${RED}Module dependencies check failed for $dir${NC}"
            missing_deps=1
        fi
    done
    
    if [ $missing_deps -eq 1 ]; then
        return 1
    fi
    echo -e "${GREEN}Module dependencies check passed.${NC}"
}

# Main function
main() {
    local exit_code=0
    
    echo "Starting validation checks..."
    
    validate_gcp_config || exit_code=1
    check_required_vars || exit_code=1
    check_terraform_fmt || exit_code=1
    validate_terraform || exit_code=1
    check_module_dependencies || exit_code=1
    run_tflint || exit_code=1
    run_checkov || exit_code=1
    run_tfsec || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\n${GREEN}All validation checks passed!${NC}"
    else
        echo -e "\n${RED}Some validation checks failed. Please fix the issues and try again.${NC}"
    fi
    
    return $exit_code
}

# Execute main function
main "$@"

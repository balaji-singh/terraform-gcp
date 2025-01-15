.PHONY: init plan apply destroy fmt validate docs test clean

ENVIRONMENT ?= dev
COMPONENT ?= all
WORKSPACE = ${ENVIRONMENT}

init:
	@echo "Initializing Terraform..."
	terraform init -backend=true

plan:
	@echo "Planning Terraform for environment: ${ENVIRONMENT}"
	terraform workspace select ${WORKSPACE} || terraform workspace new ${WORKSPACE}
	terraform plan -var-file=environments/${ENVIRONMENT}/terraform.tfvars

apply:
	@echo "Applying Terraform for environment: ${ENVIRONMENT}"
	terraform workspace select ${WORKSPACE}
	terraform apply -var-file=environments/${ENVIRONMENT}/terraform.tfvars -auto-approve

destroy:
	@echo "Destroying infrastructure in environment: ${ENVIRONMENT}"
	terraform workspace select ${WORKSPACE}
	terraform destroy -var-file=environments/${ENVIRONMENT}/terraform.tfvars -auto-approve

fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive

validate:
	@echo "Validating Terraform code..."
	terraform validate

docs:
	@echo "Generating documentation..."
	terraform-docs markdown . > README.md

test:
	@echo "Running tests..."
	go test -v ./tests/...

lint:
	@echo "Running linters..."
	tflint
	terraform fmt -check -recursive

clean:
	@echo "Cleaning up..."
	rm -rf .terraform
	find . -type f -name "*.tfstate*" -exec rm -f {} +
	find . -type f -name "*.tfplan*" -exec rm -f {} +

check-gcp:
	@echo "Checking GCP credentials..."
	gcloud auth list
	gcloud config list project

security-scan:
	@echo "Running security scan..."
	tfsec .
	checkov -d .

cost-estimate:
	@echo "Estimating costs..."
	infracost breakdown --path .

generate-graph:
	@echo "Generating dependency graph..."
	terraform graph | dot -Tpng > graph.png

help:
	@echo "Available targets:"
	@echo "  init          - Initialize Terraform"
	@echo "  plan          - Plan Terraform changes"
	@echo "  apply         - Apply Terraform changes"
	@echo "  destroy       - Destroy infrastructure"
	@echo "  fmt           - Format Terraform code"
	@echo "  validate      - Validate Terraform code"
	@echo "  docs          - Generate documentation"
	@echo "  test          - Run tests"
	@echo "  lint          - Run linters"
	@echo "  clean         - Clean up Terraform files"
	@echo "  check-gcp     - Check GCP credentials"
	@echo "  security-scan - Run security scanning tools"
	@echo "  cost-estimate - Estimate infrastructure costs"
	@echo "  generate-graph- Generate dependency graph"

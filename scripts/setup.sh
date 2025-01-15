#!/bin/bash

# Setup script for GCP Terraform environment

set -e

# Check for required tools
check_requirements() {
    echo "Checking requirements..."
    command -v terraform >/dev/null 2>&1 || { echo "terraform is required but not installed. Aborting." >&2; exit 1; }
    command -v terragrunt >/dev/null 2>&1 || { echo "terragrunt is required but not installed. Aborting." >&2; exit 1; }
    command -v gcloud >/dev/null 2>&1 || { echo "gcloud is required but not installed. Aborting." >&2; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting." >&2; exit 1; }
}

# Setup GCP authentication
setup_gcp_auth() {
    echo "Setting up GCP authentication..."
    if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo "GOOGLE_APPLICATION_CREDENTIALS environment variable not set."
        echo "Please authenticate using: gcloud auth application-default login"
        gcloud auth application-default login
    fi
}

# Enable required GCP APIs
enable_apis() {
    echo "Enabling required GCP APIs..."
    local project_id=$1
    local apis=(
        "cloudresourcemanager.googleapis.com"
        "iam.googleapis.com"
        "compute.googleapis.com"
        "container.googleapis.com"
        "secretmanager.googleapis.com"
        "cloudasset.googleapis.com"
        "cloudbuild.googleapis.com"
        "monitoring.googleapis.com"
        "logging.googleapis.com"
        "securitycenter.googleapis.com"
        "binaryauthorization.googleapis.com"
    )

    for api in "${apis[@]}"; do
        echo "Enabling $api..."
        gcloud services enable "$api" --project="$project_id"
    done
}

# Create service account for Terraform
create_terraform_sa() {
    local project_id=$1
    local sa_name="terraform"
    local sa_email="$sa_name@$project_id.iam.gserviceaccount.com"

    echo "Creating Terraform service account..."
    gcloud iam service-accounts create "$sa_name" \
        --display-name="Terraform Service Account" \
        --project="$project_id"

    # Assign required roles
    local roles=(
        "roles/editor"
        "roles/resourcemanager.projectIamAdmin"
        "roles/iam.serviceAccountAdmin"
        "roles/compute.networkAdmin"
        "roles/storage.admin"
        "roles/secretmanager.admin"
    )

    for role in "${roles[@]}"; do
        gcloud projects add-iam-policy-binding "$project_id" \
            --member="serviceAccount:$sa_email" \
            --role="$role"
    done

    # Create and download key
    gcloud iam service-accounts keys create "terraform-sa-key.json" \
        --iam-account="$sa_email" \
        --project="$project_id"
}

# Create GCS bucket for Terraform state
create_state_bucket() {
    local project_id=$1
    local region=$2
    local bucket_name="$project_id-terraform-state"

    echo "Creating GCS bucket for Terraform state..."
    gsutil mb -p "$project_id" -l "$region" "gs://$bucket_name"
    
    # Enable versioning
    gsutil versioning set on "gs://$bucket_name"
    
    # Set lifecycle policy
    cat > lifecycle.json <<EOF
{
    "rule": [
        {
            "action": {"type": "Delete"},
            "condition": {
                "numNewerVersions": 10,
                "age": 30
            }
        }
    ]
}
EOF
    gsutil lifecycle set lifecycle.json "gs://$bucket_name"
    rm lifecycle.json
}

# Main setup function
main() {
    local project_id=$1
    local region=${2:-"us-central1"}

    if [ -z "$project_id" ]; then
        echo "Usage: $0 <project_id> [region]"
        exit 1
    fi

    check_requirements
    setup_gcp_auth
    enable_apis "$project_id"
    create_terraform_sa "$project_id"
    create_state_bucket "$project_id" "$region"

    echo "Setup complete! Please set the following environment variables:"
    echo "export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/terraform-sa-key.json"
    echo "export TF_VAR_project_id=$project_id"
    echo "export TF_VAR_region=$region"
}

# Execute main function with provided arguments
main "$@"

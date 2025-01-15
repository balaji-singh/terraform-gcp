# Terraform GCP Modules

This repository contains Terraform modules for Google Cloud Platform (GCP) resources. The modules are organized by service category and follow infrastructure-as-code best practices.

## Module Categories

- Compute (GCE, GKE, App Engine, Cloud Functions, Cloud Run, Anthos)
- Storage (Cloud Storage, Persistent Disks, Filestore, Bigtable)
- Databases (Cloud SQL, Firestore, Spanner, BigQuery)
- Networking (VPC, DNS, Load Balancing, Interconnect, CDN, NAT, VPN)
- Security (IAM, Cloud Identity, KMS, Security Command Center)
- AI & ML (Vertex AI, AutoML, Cloud APIs)
- Analytics (BigQuery, Dataflow, Dataproc, Pub/Sub)
- DevOps (Cloud Build, Cloud Source Repositories, Container Registry)

## Usage

1. Clone the repository
2. Initialize Terraform:
```bash
terraform init
```
3. Configure your GCP credentials
4. Use the modules in your Terraform configurations

## Structure

```
terraform-gcp/
├── modules/          # Reusable Terraform modules
├── examples/         # Example implementations
├── compositions/     # Composite modules
├── env/             # Environment-specific configurations
└── scripts/         # Utility scripts
```

## Requirements

- Terraform >= 1.0
- Google Cloud SDK
- Valid GCP credentials

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

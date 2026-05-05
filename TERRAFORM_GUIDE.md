# Terraform â€” Init, Plan & Deploy Guide

This guide explains how to use the Terraform code in this repository for any cloud platform and environment.

---

## Repository Branch Structure

```
main                    â† this guide lives here (read-only reference)
â”œâ”€â”€ aws/pre-dev         â† developer pushes changes here first
â”œâ”€â”€ aws/dev             â† auto-deploys to AWS Development after PR merge
â”œâ”€â”€ aws/pre-test        â† developer pushes changes here first
â”œâ”€â”€ aws/test            â† auto-deploys to AWS Test after PR merge
â”œâ”€â”€ aws/pre-prod        â† developer pushes changes here first
â”œâ”€â”€ aws/prod            â† auto-deploys to AWS Production after PR merge
â”œâ”€â”€ gcp/pre-dev  â†’  gcp/dev  â†’  (same pattern)
â””â”€â”€ azure/pre-dev â†’  azure/dev â†’ (same pattern)
```

Each deployment branch (`aws/dev`, `gcp/test`, `azure/prod`, etc.) contains a `terraform/` folder with these modules:

| Module | What it provisions |
|--------|--------------------|
| `server-provisioning` | Virtual machines / EC2 / Compute instances |
| `virtual-network` | VPC, subnets, internet gateways |
| `firewall` | Security groups / NSGs / GCP firewall rules |
| `load-balancer` | ALB / GCP HTTPS LB / Azure Standard LB |
| `managed-sql` | RDS / Cloud SQL / Azure PostgreSQL |
| `object-storage` | S3 / GCS / Azure Blob Storage |
| `dns` | Route 53 / Cloud DNS / Azure Private DNS |
| `storage` | EBS / Persistent Disk / Azure Disk |
| `iam` | Roles, policies, service accounts |
| `monitoring` | CloudWatch / Cloud Monitoring / Azure Monitor |
| `backup` | AWS Backup / GCP snapshots / Azure Backup |
| `db-migration` | DMS / Database migration services |
| `secrets` | Secrets Manager / Secret Manager / Key Vault |

---

## Prerequisites

### 1. Install Terraform
```bash
# Windows (chocolatey)
choco install terraform

# Mac
brew install terraform

# Verify installation
terraform -version
```

### 2. Install Cloud CLI & Authenticate

**AWS:**
```bash
# Install AWS CLI
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (e.g. us-east-1)
```

**GCP:**
```bash
# Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

**Azure:**
```bash
# Install Azure CLI
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

---

## Step-by-Step Deployment

### Step 1 â€” Clone the repository and switch to the correct branch

```bash
git clone https://github.com/Monali1109/infrabot-GenAI-Terraform-IAC-automation.git
cd infrabot-GenAI-Terraform-IAC-automation

# Switch to the branch for your cloud + environment
# Format: git checkout {cloud}/{env}

git checkout aws/dev       # AWS Development
git checkout aws/test      # AWS Test
git checkout aws/prod      # AWS Production

git checkout gcp/dev       # GCP Development
git checkout gcp/test      # GCP Test
git checkout gcp/prod      # GCP Production

git checkout azure/dev     # Azure Development
git checkout azure/test    # Azure Test
git checkout azure/prod    # Azure Production
```

---

### Step 2 â€” Navigate to the module you want to deploy

```bash
cd terraform/<module-name>

# Examples:
cd terraform/server-provisioning
cd terraform/firewall
cd terraform/virtual-network
```

---

### Step 3 â€” terraform init

Initialises the working directory, downloads provider plugins.

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws...
Terraform has been successfully initialized!
```

> Run `terraform init` every time you:
> - Clone the repo fresh
> - Add a new provider
> - Change the backend configuration

---

### Step 4 â€” Review and set variables

Each module has a `variables.tf` file. Check what values are needed:

```bash
cat variables.tf
```

Set values either in `terraform.tfvars` (create one if missing):

```hcl
# terraform.tfvars example for AWS server-provisioning
subnet_id         = "subnet-xxxxxxxxxx"
key_name          = "my-key-pair"
availability_zone = "us-east-1a"
```

Or pass them directly on the command line:
```bash
terraform plan -var="subnet_id=subnet-xxxxxxxxxx" -var="key_name=my-key-pair"
```

---

### Step 5 â€” terraform plan

Shows exactly what Terraform will create, change, or destroy. **No changes are made yet.**

```bash
terraform plan
```

Expected output:
```
Terraform will perform the following actions:

  # aws_instance.awsappdv01 will be created
  + resource "aws_instance" "awsappdv01" {
      + ami           = "ami-0a91cd140a1fc148a"
      + instance_type = "c5.xlarge"
      ...
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

> Always review the plan output carefully before applying.
> Look for unexpected `destroy` or `change` actions.

Save the plan to a file (recommended for production):
```bash
terraform plan -out=tfplan
```

---

### Step 6 â€” terraform apply (Deploy)

Applies the changes shown in the plan. **This provisions real infrastructure.**

```bash
# Apply interactively (will ask "Do you want to perform these actions?")
terraform apply

# Apply using saved plan file (skips confirmation prompt)
terraform apply tfplan

# Apply without interactive prompt (use carefully in automation/CI-CD)
terraform apply -auto-approve
```

Expected output:
```
aws_instance.awsappdv01: Creating...
aws_instance.awsappdv01: Still creating... [10s elapsed]
aws_instance.awsappdv01: Creation complete after 42s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

---

### Step 7 â€” Verify deployment

```bash
# Show current state of provisioned resources
terraform show

# List all resources in state
terraform state list

# Show details of a specific resource
terraform state show aws_instance.awsappdv01
```

---

## Deploying All Modules in Order (Full Environment)

Deploy modules in this recommended order (dependencies flow top to bottom):

```bash
# 1. Network first (everything depends on this)
cd terraform/virtual-network && terraform init && terraform apply -auto-approve && cd ../..

# 2. Firewall / Security Groups
cd terraform/firewall && terraform init && terraform apply -auto-approve && cd ../..

# 3. Servers
cd terraform/server-provisioning && terraform init && terraform apply -auto-approve && cd ../..

# 4. Load Balancer
cd terraform/load-balancer && terraform init && terraform apply -auto-approve && cd ../..

# 5. Database
cd terraform/managed-sql && terraform init && terraform apply -auto-approve && cd ../..

# 6. Storage
cd terraform/object-storage && terraform init && terraform apply -auto-approve && cd ../..

# 7. DNS
cd terraform/dns && terraform init && terraform apply -auto-approve && cd ../..

# 8. Remaining (IAM, Monitoring, Backup, Secrets)
cd terraform/iam && terraform init && terraform apply -auto-approve && cd ../..
cd terraform/monitoring && terraform init && terraform apply -auto-approve && cd ../..
cd terraform/backup && terraform init && terraform apply -auto-approve && cd ../..
cd terraform/secrets && terraform init && terraform apply -auto-approve && cd ../..
```

---

## Making Changes (Developer Workflow)

**Never push directly to `aws/dev`, `gcp/test`, `azure/prod` etc.**

```bash
# 1. Switch to the pre- branch for your target
git checkout aws/pre-dev

# 2. Make your Terraform changes
#    (edit files, add new resources, etc.)

# 3. Commit and push
git add .
git commit -m "feat: add new firewall rule for port 8080"
git push origin aws/pre-dev

# 4. Raise a Pull Request on GitHub:
#    aws/pre-dev  â†’  aws/dev
#
# 5. After PR review and approval â†’ merge
#    This triggers deployment to AWS dev environment
```

---

## Destroy Infrastructure (Use with Caution)

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy a specific module
cd terraform/server-provisioning
terraform destroy

# Destroy everything in the environment (run from each module)
terraform destroy -auto-approve
```

> Never run `terraform destroy` on `prod` without approval.

---

## Common Issues & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Error: No valid credential sources found` | Not authenticated to cloud | Run `aws configure` / `gcloud auth` / `az login` |
| `Error: Failed to query available provider packages` | No internet or proxy | Check network / VPN |
| `Error: Provider configuration not present` | Wrong branch checked out | Run `git checkout {cloud}/{env}` |
| `Error initializing state` | Backend not configured | Run `terraform init` first |
| `ResourceAlreadyExists` | Resource name already taken | Check naming guide â€” increment suffix (e.g. `-02`) |

---

## Quick Reference

```bash
terraform init          # Initialise â€” run once per module
terraform validate      # Check syntax without connecting to cloud
terraform fmt           # Auto-format .tf files
terraform plan          # Preview changes (dry run)
terraform apply         # Deploy changes
terraform show          # Show current state
terraform state list    # List all managed resources
terraform destroy       # Remove all resources in module
```

---

*Maintained by: mopatil@deloitte.com*

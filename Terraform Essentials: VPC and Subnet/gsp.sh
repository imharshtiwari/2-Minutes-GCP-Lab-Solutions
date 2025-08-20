#!/bin/bash
# ======================================================
# Terraform + Google Cloud VPC Creation Lab - SPARKWAVE
# ======================================================

# --- Variables ---
PROJECT_ID=$(gcloud config get-value project 2> /dev/null)

if [[ -z "$PROJECT_ID" ]]; then
  echo "❌ No active project found. Please set a project first:"
  echo "   gcloud config set project PROJECT_ID"
  exit 1
fi

# Ask for region and zone
read -p "Enter region [us-west1]: " REGION
REGION=${REGION:-us-west1}

read -p "Enter zone [us-west1-b]: " ZONE
ZONE=${ZONE:-us-west1-b}

BUCKET_NAME="${PROJECT_ID}-terraform-state"

# --- Step 1: Set gcloud Config ---
echo "🔹 Setting Google Cloud configuration..."
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# --- Step 2: Create GCS Bucket ---
echo "🔹 Creating Cloud Storage bucket for Terraform state..."
gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_ID --location=us

# --- Step 3: Enable Required API ---
echo "🔹 Enabling Cloud Resource Manager API..."
gcloud services enable cloudresourcemanager.googleapis.com --project=$PROJECT_ID

# --- Step 4: Create Terraform Files ---
echo "🔹 Creating Terraform configuration files..."
mkdir -p terraform-vpc
cd terraform-vpc

# main.tf
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "$BUCKET_NAME"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "$PROJECT_ID"
  region  = "$REGION"
}

resource "google_compute_network" "vpc_network" {
  name                    = "custom-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_us" {
  name            = "subnet-us"
  ip_cidr_range   = "10.10.1.0/24"
  region          = "$REGION"
  network         = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}
EOF

# variables.tf
cat > variables.tf <<EOF
variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project"
  default     = "$PROJECT_ID"
}

variable "region" {
  type        = string
  description = "The region to deploy resources in"
  default     = "$REGION"
}
EOF

# outputs.tf
cat > outputs.tf <<EOF
output "network_name" {
  value       = google_compute_network.vpc_network.name
  description = "The name of the VPC network"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet_us.name
  description = "The name of the subnetwork"
}
EOF

# --- Step 5: Initialize & Apply Terraform ---
echo "🔹 Initializing Terraform..."
terraform init

echo "🔹 Planning Terraform deployment..."
terraform plan

echo "🔹 Applying Terraform configuration..."
terraform apply --auto-approve

# --- Step 6: Verification ---
echo "✅ Verifying created resources..."
echo "VPC Networks:"
gcloud compute networks list --filter="name=custom-vpc-network"

echo "Subnets:"
gcloud compute networks subnets list --filter="name=subnet-us"

echo "Firewall Rules:"
gcloud compute firewall-rules list --filter="name~'allow-ssh|allow-icmp'"

# --- Step 7: Cleanup ---
echo "⚠️ Destroying resources to avoid charges..."
terraform destroy --auto-approve

cd ..
rm -rf terraform-vpc

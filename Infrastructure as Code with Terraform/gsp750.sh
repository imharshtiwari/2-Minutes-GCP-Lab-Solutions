#!/bin/bash


# Modern Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Box Drawing Characters
BOX_TOP="${BLUE}╔════════════════════════════════════════════╗${NC}"
BOX_MID="${BLUE}║                                            ║${NC}"
BOX_BOT="${BLUE}╚════════════════════════════════════════════╝${NC}"

# Header with branding
clear
echo -e "${BOX_TOP}"
echo -e "${BLUE}║   🚀 Terraform Infrastructure Deployment   ║${NC}"
echo -e "${BOX_BOT}"
echo -e "${CYAN}📺 YouTube: ${WHITE}https://youtube.com/@sparkwave.01${NC}"
echo -e "${CYAN}⭐ Subscribe for more DevOps tutorials! ⭐${NC}"
echo

# Set environment variables
echo -e "${YELLOW}🌍 Configuring Project Settings${NC}"
export REGION=${ZONE%-*}
export PROJECT_ID=$(gcloud config get-value project)
echo -e "${GREEN}✅ Project ID: ${WHITE}$PROJECT_ID${NC}"
echo -e "${GREEN}✅ Region: ${WHITE}$REGION${NC}"
echo -e "${GREEN}✅ Zone: ${WHITE}$ZONE${NC}"
echo

cat <<'EOF' > ~/.customize_environment
# Set up HashiCorp repository and install Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF
bash ~/.customize_environment

# Phase 1: Network Deployment
echo -e "${YELLOW}🛠️ Phase 1: Deploying Network Infrastructure${NC}"
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  version = "3.5.0"
  project = "$PROJECT_ID"
  region  = "$REGION"
  zone    = "$ZONE"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
EOF

terraform init
terraform apply -auto-approve

# Phase 2: Basic VM Deployment
echo -e "\n${YELLOW}🖥️ Phase 2: Deploying Basic VM Instance${NC}"
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  version = "3.5.0"
  project = "$PROJECT_ID"
  region  = "$REGION"
  zone    = "$ZONE"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}
EOF

terraform apply -auto-approve

# Phase 3: Tagged VM Deployment
echo -e "\n${YELLOW}🏷️ Phase 3: Adding Tags to VM${NC}"
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  version = "3.5.0"
  project = "$PROJECT_ID"
  region  = "$REGION"
  zone    = "$ZONE"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}
EOF

terraform apply -auto-approve

# Phase 4: COS Image Deployment
echo -e "\n${YELLOW}🖼️ Phase 4: Switching to COS Image${NC}"
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  version = "3.5.0"
  project = "$PROJECT_ID"
  region  = "$REGION"
  zone    = "$ZONE"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}
EOF

terraform apply -auto-approve

# Phase 5: Static IP Configuration
echo -e "\n${YELLOW}📡 Phase 5: Configuring Static IP${NC}"
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  version = "3.5.0"
  project = "$PROJECT_ID"
  region  = "$REGION"
  zone    = "$ZONE"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
}
resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
EOF

terraform plan -out static_ip
terraform apply "static_ip"

# Phase 6: Storage Bucket Deployment
echo -e "\n${YELLOW}🪣 Phase 6: Deploying Storage Bucket${NC}"
cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  version = "3.5.0"
  project = "$PROJECT_ID"
  region  = "$REGION"
  zone    = "$ZONE"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
}
resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
resource "google_storage_bucket" "example_bucket" {
  name     = "$PROJECT_ID"
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
resource "google_compute_instance" "another_instance" {
  depends_on   = [google_storage_bucket.example_bucket]
  name         = "terraform-instance-2"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {}
  }
}
EOF

terraform plan
terraform apply -auto-approve

# Completion message
echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════╗"
echo -e "║          🎉 Deployment Completed! 🎉          ║"
echo -e "╚════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}Thank you for using SPARKWAVE ✨'s Cloud Lab!${NC}"
echo -e "${CYAN}For more tutorials: ${WHITE}https://youtube.com/@sparkwave.01${NC}"

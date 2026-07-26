BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

clear

echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}          SUBSCRIBE SPARKWAVE DEV - INITIATING EXECUTION...        ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

print_phase "1" "🌍  Detecting Project & Region"
export PROJECT_ID=$(gcloud config get-value project)

if [ -n "$ALLOWED_REGION_OVERRIDE" ]; then
  export REGION="$ALLOWED_REGION_OVERRIDE"
  info "Using manual override region"
elif [ -n "$GOOGLE_CLOUD_REGION" ]; then
  export REGION="$GOOGLE_CLOUD_REGION"
  info "Region sourced from \$GOOGLE_CLOUD_REGION"
elif [ -n "$CLOUDSHELL_ENVIRONMENT" ]; then
  DETECTED_ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items.google-compute-default-zone)")
  if [ -n "$DETECTED_ZONE" ]; then
    export REGION=$(echo "$DETECTED_ZONE" | sed 's/-[a-z]$//')
    info "Region derived from Cloud Shell default zone"
  fi
fi

if [ -z "$REGION" ]; then
  DETECTED_ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $NF}')
  if [ -n "$DETECTED_ZONE" ]; then
    export REGION=$(echo "$DETECTED_ZONE" | sed 's/-[a-z]$//')
    info "Region derived from instance metadata"
  fi
fi

if [ -z "$REGION" ] || [ "$REGION" == "null" ]; then
  export REGION="us-central1"
  warn "Falling back to default region us-central1"
fi

success "Project ID: ${WHITE}$PROJECT_ID${NC}"
success "Region:     ${WHITE}$REGION${NC}"

# ----------------------------- Phase 2: Terraform Install -------------------------
print_phase "2" "📦  Installing Terraform"
cat << 'EOF' > ~/.customize_environment
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF
bash ~/.customize_environment
success "Terraform installed: $(terraform --version | head -n1)"

# ----------------------------- Phase 3: Task 1 - VPC Module -------------------------
print_phase "3" "🛠️   Task 1: Deploying VPC via Registry Module"
cd ~ || exit
rm -rf terraform-google-network
git clone https://github.com/terraform-google-modules/terraform-google-network
cd terraform-google-network/examples/simple_project || exit
git checkout tags/v6.0.1 -b v6.0.1
success "Repository cloned and checked out at v6.0.1"

gcloud services enable cloudaicompanion.googleapis.com 2>/dev/null || warn "Could not enable Gemini API (non-blocking, continuing)"

cat << EOF > variables.tf
variable "project_id" {
  description = "The project ID to host the network in"
  default     = "$PROJECT_ID"
}
variable "network_name" {
  description = "The name of the network to be created"
  default     = "example-vpc"
}
EOF

cat << EOF > main.tf
module "test-vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.project_id
  network_name = var.network_name
  mtu          = 1460
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "$REGION"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "$REGION"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name               = "subnet-03"
      subnet_ip                 = "10.10.30.0/24"
      subnet_region             = "$REGION"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_filter   = "false"
    }
  ]
}
EOF

terraform init
terraform apply -auto-approve
success "VPC network and subnets deployed  (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 4: Task 2 - Storage Module -------------------------
print_phase "4" "🪣  Task 2: Deploying Custom Storage Bucket Module"
rm -rf ~/gcp-storage-lab
mkdir -p ~/gcp-storage-lab/modules/gcp_storage_bucket
cd ~/gcp-storage-lab || exit

cat << EOF > main.tf
provider "google" {
  project = "$PROJECT_ID"
  region  = "$REGION"
}

module "gcp_storage_bucket" {
  source      = "./modules/gcp_storage_bucket"
  bucket_name = "${PROJECT_ID}-bucket"
}
EOF

cd modules/gcp_storage_bucket || exit

cat << 'EOF' > variables.tf
variable "bucket_name" {
  description = "The name of the storage bucket"
  type        = string
}
EOF

cat << EOF > main.tf
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = "$REGION"
  force_destroy = true
}

resource "google_storage_bucket_object" "index" {
  name    = "index.html"
  bucket  = google_storage_bucket.bucket.name
  content = "<html><body><h1>Welcome to my website!</h1></body></html>"
}

resource "google_storage_bucket_object" "error" {
  name    = "error.html"
  bucket  = google_storage_bucket.bucket.name
  content = "<html><body><h1>Error: Page not found!</h1></body></html>"
}
EOF

cd ../../ || exit
terraform init
terraform apply -auto-approve
success "Storage bucket module deployed  (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 5: Destroy Task 1 -------------------------
print_phase "5" "🧹  Cleaning Up Task 1 Infrastructure"
info "Lab requirement: Task 1 resources must be destroyed after Task 2 is verified"
cd ~/terraform-google-network/examples/simple_project || exit
terraform destroy -auto-approve
success "Task 1 infrastructure destroyed  (⏱  $(elapsed_since_start)s elapsed)"

# Final message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwavedev${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Don't forget to Like, Share and Subscribe for more Videos${RESET_FORMAT}"
echo

#!/bin/bash

# Color codes for formatting
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
NC='\e[0m' # No Color

# Function to display spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to print section header
print_header() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} ${CYAN}$1${NC} ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to print warning message
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Welcome message with animation
echo -e "${CYAN}"
cat << "EOF"
  _    _ _   _ _ _ _          _   _           _     
 | |  | | | | | | | |        | | | |         | |    
 | |  | | | | | | | | ___  __| | | |__   __ _| |__  
 | |  | | | | | | | |/ _ \/ _` | | '_ \ / _` | '_ \ 
 | |__| | |_| | | | |  __/ (_| | | | | | (_| | | | |
  \____/ \___/|_|_|_|\___|\__,_| |_| |_|\__,_|_| |_|
EOF
echo -e "${NC}"

#  SPARKWAVE ✨ YouTube promotion with spinner
echo -e "${YELLOW}📺 Welcome to Kubernetes Lab!${NC}"
echo -e "${MAGENTA}🌟 Don't forget to subscribe to:${NC}"
echo -e "${CYAN}    SPARKWAVE ✨ YouTube Channel:${NC} ${WHITE}https://www.youtube.com/@drSPARKWAVE ✨.5460/videos${NC}"
echo -ne "${GREEN}   Subscribing in progress:${NC} "
(sleep 3) & spinner $!
echo -e "${GREEN}✅ Subscribed! Thank you for your support!${NC}"

# Fetch zone and region
print_header "Fetching Google Cloud Configuration"
print_info "Getting zone, region, and project details..."
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])" 2>/dev/null)
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$ZONE" ] || [ -z "$REGION" ] || [ -z "$PROJECT_ID" ]; then
    print_error "Failed to get Google Cloud configuration. Please check your gcloud setup."
    exit 1
fi

print_success "Zone: $ZONE"
print_success "Region: $REGION"
print_success "Project ID: $PROJECT_ID"

# Set compute zone
print_info "Setting compute zone..."
gcloud config set compute/zone $ZONE

# Copy Kubernetes files
print_header "Setting up Kubernetes Resources"
print_info "Copying Kubernetes configuration files..."
gcloud storage cp -r gs://spls/gsp053/kubernetes . &
spinner $!
cd kubernetes

# Create GKE cluster
print_header "Creating GKE Cluster"
print_info "Creating Kubernetes cluster with 3 nodes..."
gcloud container clusters create bootcamp \
  --machine-type e2-small \
  --num-nodes 3 \
  --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw" &
spinner $!
print_success "GKE cluster created successfully!"

# TASK 2 - Deployments
print_header "TASK 2: Deploying Fortune App (Blue)"
print_info "Creating deployment and service..."
kubectl create -f deployments/fortune-app-blue.yaml &
spinner $!
kubectl create -f services/fortune-app.yaml &
spinner $!

print_info "Scaling deployment to 5 replicas..."
kubectl scale deployment fortune-app-blue --replicas=5 &
spinner $!
COUNT=$(kubectl get pods | grep fortune-app-blue | wc -l | tr -d ' ')
print_success "Current replicas: $COUNT"

print_info "Scaling deployment to 3 replicas..."
kubectl scale deployment fortune-app-blue --replicas=3 &
spinner $!
COUNT=$(kubectl get pods | grep fortune-app-blue | wc -l | tr -d ' ')
print_success "Current replicas: $COUNT"

# TASK 3 - Confirmation
print_header "TASK 3: Canary Deployment"
echo -e "${YELLOW}🎯 This task will perform a canary deployment strategy${NC}"
echo -ne "${CYAN}? Do you want to continue with Task 3? ${NC}[${GREEN}Y${NC}/${RED}N${NC}]: "
read -r CONFIRM

if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then
    print_warning "Task 3 aborted by user."
    exit 0
fi

print_info "Updating container image to version 2.0.0..."
kubectl set image deployment/fortune-app-blue fortune-app=$REGION-docker.pkg.dev/qwiklabs-resources/spl-lab-apps/fortune-service:2.0.0 &
spinner $!

print_info "Setting environment variable..."
kubectl set env deployment/fortune-app-blue APP_VERSION=2.0.0 &
spinner $!

print_info "Creating canary deployment..."
kubectl create -f deployments/fortune-app-canary.yaml &
spinner $!
print_success "Canary deployment created successfully!"

# TASK 5 - Blue-Green Deployment
print_header "TASK 5: Blue-Green Deployment"
print_info "Setting up blue service..."
kubectl apply -f services/fortune-app-blue-service.yaml &
spinner $!

print_info "Creating green deployment..."
kubectl create -f deployments/fortune-app-green.yaml &
spinner $!

print_info "Setting up green service..."
kubectl apply -f services/fortune-app-green-service.yaml &
spinner $!

print_info "Updating blue service..."
kubectl apply -f services/fortune-app-blue-service.yaml &
spinner $!

print_success "Blue-Green deployment setup completed!"

# Final message
print_header "Lab Completion Status"
echo -e "${GREEN}🎉 All tasks completed successfully!${NC}"
echo -e "${CYAN}📊 Current deployments:${NC}"
kubectl get deployments
echo -e "\n${CYAN}🌐 Current services:${NC}"
kubectl get services
echo -e "\n${CYAN}🐳 Current pods:${NC}"
kubectl get pods

echo -e "\n${MAGENTA}=================================================${NC}"
echo -e "${YELLOW}🙏 Thank you for completing the lab!${NC}"
echo -e "${CYAN}📚 Don't forget to explore more content from:${NC}"
echo -e "${WHITE}    SPARKWAVE ✨ - https://www.youtube.com/@SPARKWAVE.01"
echo -e "${MAGENTA}=================================================${NC}"

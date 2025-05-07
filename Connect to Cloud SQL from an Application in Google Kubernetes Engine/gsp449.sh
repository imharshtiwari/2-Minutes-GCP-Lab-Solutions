#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

echo
echo "${CYAN_TEXT}${BOLD_TEXT}=========================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🚀         INITIATING EXECUTION         🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=========================================${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Verifying active Google Cloud account...${RESET_FORMAT}"
gcloud auth list

echo
echo "${GREEN_TEXT}${BOLD_TEXT}🛠️  Determining and setting the default Google Cloud Zone for this session...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo "${WHITE_TEXT}Zone set to: ${BOLD_TEXT}$ZONE${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}🛠️  Determining and setting the default Google Cloud Region for this session...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo "${WHITE_TEXT}Region set to: ${BOLD_TEXT}$REGION${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}🆔 Fetching and setting the current Google Cloud Project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
echo "${WHITE_TEXT}Project ID set to: ${BOLD_TEXT}$PROJECT_ID${RESET_FORMAT}"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}⚙️  Configuring gcloud to use the determined default zone (${ZONE})...${RESET_FORMAT}"
gcloud config set compute/zone "$ZONE"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}⚙️  Configuring gcloud to use the determined default region (${REGION})...${RESET_FORMAT}"
gcloud config set compute/region "$REGION"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}📥 Downloading the demo application archive from Google Cloud Storage...${RESET_FORMAT}"
gsutil cp gs://spls/gsp449/gke-cloud-sql-postgres-demo.tar.gz .

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}📦 Extracting the downloaded demo application archive...${RESET_FORMAT}"
tar -xzvf gke-cloud-sql-postgres-demo.tar.gz

echo
echo "${CYAN_TEXT}${BOLD_TEXT}📁 Changing directory to the extracted demo application folder...${RESET_FORMAT}"
cd gke-cloud-sql-postgres-demo

echo
echo "${GREEN_TEXT}${BOLD_TEXT}📧 Retrieving the active gcloud account email for PostgreSQL setup...${RESET_FORMAT}"
PG_EMAIL=$(gcloud config get-value account)
echo "${WHITE_TEXT}PostgreSQL admin email will be: ${BOLD_TEXT}$PG_EMAIL${RESET_FORMAT}"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}🚀 Executing the setup script for the demo application. This may take a few moments, please wait...${RESET_FORMAT}"
./create.sh dbadmin $PG_EMAIL

echo
echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Initializing resources...${RESET_FORMAT}"
for i in $(seq 10 -1 1); do
  echo -ne "${BLUE_TEXT}${BOLD_TEXT}⏳ ${i} seconds remaining...${RESET_FORMAT}\r"
  sleep 1
done
echo -ne "\n"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Resources initialized.${RESET_FORMAT}"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}🔍 Identifying the Pod ID for the deployed application in the default namespace...${RESET_FORMAT}"
POD_ID=$(kubectl --namespace default get pods -o name | cut -d '/' -f 2)
echo "${WHITE_TEXT}Application Pod ID: ${BOLD_TEXT}$POD_ID${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}🌐 Exposing the application Pod (${POD_ID}) as a LoadBalancer service on port 80...${RESET_FORMAT}"
kubectl expose pod $POD_ID --port=80 --type=LoadBalancer

echo
echo "${CYAN_TEXT}${BOLD_TEXT}📋 Displaying all services in the default namespace, including the new LoadBalancer...${RESET_FORMAT}"
kubectl get svc

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 Enjoyed this script and the video? Consider subscribing to SparkWave 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwave.01${RESET_FORMAT}"
echo

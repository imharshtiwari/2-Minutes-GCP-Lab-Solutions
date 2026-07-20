#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ---------- Color variables ----------
BLACK=`tput setaf 0 2>/dev/null || echo ''`
RED=`tput setaf 1 2>/dev/null || echo ''`
GREEN=`tput setaf 2 2>/dev/null || echo ''`
YELLOW=`tput setaf 3 2>/dev/null || echo ''`
BLUE=`tput setaf 4 2>/dev/null || echo ''`
MAGENTA=`tput setaf 5 2>/dev/null || echo ''`
CYAN=`tput setaf 6 2>/dev/null || echo ''`
WHITE=`tput setaf 7 2>/dev/null || echo ''`

BG_BLACK=`tput setab 0 2>/dev/null || echo ''`
BG_RED=`tput setab 1 2>/dev/null || echo ''`
BG_GREEN=`tput setab 2 2>/dev/null || echo ''`
BG_YELLOW=`tput setab 3 2>/dev/null || echo ''`
BG_BLUE=`tput setab 4 2>/dev/null || echo ''`
BG_MAGENTA=`tput setab 5 2>/dev/null || echo ''`
BG_CYAN=`tput setab 6 2>/dev/null || echo ''`
BG_WHITE=`tput setab 7 2>/dev/null || echo ''`

BOLD=`tput bold 2>/dev/null || echo ''`
RESET=`tput sgr0 2>/dev/null || echo ''`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

# Random Thank You Messages
THANK_YOU_MESSAGES=(
    "Thanks for providing the details!"
    "Appreciate your input!"
    "Your details have been recorded!"
    "Thanks for your response!"
    "Your input is valuable, thank you!"
)
RANDOM_THANK_YOU=${THANK_YOU_MESSAGES[$RANDOM % ${#THANK_YOU_MESSAGES[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${CYAN}${BOLD}Welcome to Dr. Abhishek Cloud Tutorials${RESET}"
echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"
echo "${YELLOW}Subscribe here 👉 https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# ---------- defaults for the lab ----------
DEFAULT_REPO="valkyrie-docker-repo"
DEFAULT_IMG="valkyrie-dev"
DEFAULT_TAG="v0.0.1"
DEFAULT_REGION="us-west1"
DEFAULT_ZONE="us-west1-b"

# interactive prompt but with sensible defaults
read -p "Enter Repository Name [${DEFAULT_REPO}]: " REPO
REPO=${REPO:-$DEFAULT_REPO}

read -p "Enter Docker Image name [${DEFAULT_IMG}]: " DCKR_IMG
DCKR_IMG=${DCKR_IMG:-$DEFAULT_IMG}

read -p "Enter Tag [${DEFAULT_TAG}]: " TAG
TAG=${TAG:-$DEFAULT_TAG}

read -p "Enter Region [${DEFAULT_REGION}]: " REGION
REGION=${REGION:-$DEFAULT_REGION}

read -p "Enter Zone [${DEFAULT_ZONE}]: " ZONE
ZONE=${ZONE:-$DEFAULT_ZONE}

echo
echo "${RANDOM_TEXT_COLOR}${BOLD}$RANDOM_THANK_YOU${RESET}"
echo

# ---------- project detection ----------
PROJECT_ID=${DEVSHELL_PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}
if [ -z "$PROJECT_ID" ]; then
  echo "${RED}ERROR: No GCP project found. Set DEVSHELL_PROJECT_ID or run 'gcloud config set project <project-id>'${RESET}"
  exit 1
fi
echo "${CYAN}Using project: $PROJECT_ID${RESET}"
echo "${CYAN}Zone: $ZONE, Region: $REGION${RESET}"
echo

# ---------- Download & prepare app source ----------
echo "${GREEN}Downloading and extracting valkyrie-app...${RESET}"
if [ ! -f valkyrie-app.tgz ] && [ ! -d valkyrie-app ]; then
  gsutil cp gs://spls/gsp318/valkyrie-app.tgz .
fi

if [ -f valkyrie-app.tgz ] && [ ! -d valkyrie-app ]; then
  tar -xzf valkyrie-app.tgz
fi

if [ ! -d valkyrie-app ]; then
  echo "${RED}ERROR: valkyrie-app not found after download. Aborting.${RESET}"
  exit 1
fi

cd valkyrie-app

# ---------- Create Dockerfile (lab-specified) ----------
echo "${YELLOW}Creating Dockerfile...${RESET}"
cat > Dockerfile <<'EOF'
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

# ---------- Build & Push: use Cloud Build (no local Docker daemon needed) ----------
IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${DCKR_IMG}:${TAG}"
echo "${BLUE}Will build & push image to Artifact Registry at:${RESET} ${IMAGE_PATH}"
echo

# Ensure Artifact Registry repo exists (synchronous)
if ! gcloud artifacts repositories describe "$REPO" --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
  echo "${YELLOW}Creating Artifact Registry repository: $REPO in $REGION${RESET}"
  gcloud artifacts repositories create "$REPO" \
    --repository-format=docker \
    --location="$REGION" \
    --description="valkyrie lab repo" \
    --project="$PROJECT_ID"
else
  echo "${GREEN}Artifact Registry repo $REPO already exists in $REGION${RESET}"
fi

# Configure Docker auth helper (safe even when using Cloud Build)
echo "${BLUE}Configuring Docker authentication helper for Artifact Registry...${RESET}"
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet || true

# Build & push with Cloud Build (recommended inside Cloud Shell)
echo "${BLUE}Submitting build to Cloud Build (this will build and push the image)...${RESET}"
gcloud builds submit --tag "${IMAGE_PATH}" .

# Optional verification (best-effort)
echo "${CYAN}Verifying image in Artifact Registry (describe may fail in some environments but that's okay)...${RESET}"
if ! gcloud artifacts docker images describe "${IMAGE_PATH}" --project="$PROJECT_ID" --location="$REGION" >/dev/null 2>&1; then
  echo "${YELLOW}Warning: unable to describe image (it might still be available). Continue...${RESET}"
fi

# ---------- Optional local docker smoke test (only if Docker daemon available) ----------
if command -v docker >/dev/null 2>&1; then
  echo "${BLUE}Local docker detected. Building local image for smoke test...${RESET}"
  docker build -t "${DCKR_IMG}:${TAG}" .
  docker run -d -p 8080:8080 --name "${DCKR_IMG}_${TAG}" "${DCKR_IMG}:${TAG}" || echo "${YELLOW}Local docker run failed (may be fine in Cloud Shell)${RESET}"
else
  echo "${YELLOW}No local Docker daemon detected in this environment — skipping local run.${RESET}"
fi

# ---------- Update k8s deployment manifest with pushed image ----------
if [ -f k8s/deployment.yaml ]; then
  echo "${GREEN}Updating k8s/deployment.yaml with image ${IMAGE_PATH}${RESET}"
  sed -i.bak "s#IMAGE_HERE#${IMAGE_PATH}#g" k8s/deployment.yaml
else
  echo "${RED}ERROR: k8s/deployment.yaml not found in valkyrie-app/k8s. Aborting.${RESET}"
  exit 1
fi

# ---------- Ensure GKE cluster exists (create if missing) ----------
CLUSTER_NAME="valkyrie-dev"
if ! gcloud container clusters list --project "$PROJECT_ID" --format="value(name)" | grep -q "^${CLUSTER_NAME}$"; then
  echo "${YELLOW}Cluster ${CLUSTER_NAME} not found in project ${PROJECT_ID}. Creating in zone ${ZONE}...${RESET}"
  gcloud container clusters create "$CLUSTER_NAME" --zone "$ZONE" --num-nodes=1 --project "$PROJECT_ID"
else
  echo "${GREEN}Cluster ${CLUSTER_NAME} already exists.${RESET}"
fi

# ---------- Get credentials and test kubectl connectivity ----------
echo "${CYAN}Fetching credentials for cluster ${CLUSTER_NAME} (zone: ${ZONE})...${RESET}"
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE" --project "$PROJECT_ID"

echo "${CYAN}Checking kubectl connectivity...${RESET}"
if ! kubectl get nodes >/dev/null 2>&1; then
  echo "${RED}ERROR: kubectl cannot reach the cluster. Aborting.${RESET}"
  exit 1
fi

# ---------- Deploy to Kubernetes (idempotent) ----------
echo "${BLUE}Deploying manifests to cluster...${RESET}"
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# ---------- Wait for external IP if service is LoadBalancer ----------
SERVICE_NAME=$(grep -E "name:\s*" k8s/service.yaml | head -n1 | awk '{print $2}' || true)
if [ -n "$SERVICE_NAME" ]; then
  echo "${CYAN}Waiting for external IP for service ${SERVICE_NAME} (this may take 30-90s)...${RESET}"
  for i in {1..40}; do
    EX_IP=$(kubectl get svc "$SERVICE_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    if [ -n "$EX_IP" ]; then
      echo "${GREEN}Service external IP: ${EX_IP}${RESET}"
      break
    fi
    echo -n "."
    sleep 5
  done
  echo
else
  echo "${YELLOW}Could not auto-detect service name. Check k8s/service.yaml manually.${RESET}"
fi

echo
echo "${GREEN}${BOLD}Congrats — lab tasks attempted/completed (check GKE console to verify).${RESET}"
echo "${CYAN}Deployed image: ${IMAGE_PATH}${RESET}"
echo "${YELLOW}Subscribe here 👉 https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Optional cleanup helper (disabled by default)
remove_files() {
  for file in *; do
    if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
      if [[ -f "$file" ]]; then
        rm -f "$file"
        echo "Removed: $file"
      fi
    fi
  done
}
# remove_files   # uncomment to enable

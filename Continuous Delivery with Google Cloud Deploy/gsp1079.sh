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
echo "${CYAN_TEXT}${BOLD_TEXT}===================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🚀     INITIATING EXECUTION     🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}===================================${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🛠️ Attempting to determine the default Google Cloud Zone...${RESET_FORMAT}"
ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)

if [ -z "$ZONE" ]; then
  echo "${YELLOW_TEXT}${BOLD_TEXT}🤔 Default zone could not be auto-detected.${RESET_FORMAT}"
  while [ -z "$ZONE" ]; do
    read -p "${WHITE_TEXT}${BOLD_TEXT}⌨️ Please enter the ZONE: ${RESET_FORMAT}" ZONE
    if [ -z "$ZONE" ]; then
      echo "${RED_TEXT}${BOLD_TEXT}🚫 Zone cannot be empty. Please provide a valid zone.${RESET_FORMAT}"
    fi
  done
fi
export ZONE
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Zone set to: $ZONE${RESET_FORMAT}"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}🛠️ Attempting to determine the default Google Cloud Region...${RESET_FORMAT}"
REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])" 2>/dev/null)

if [ -z "$REGION" ]; then
  echo "${YELLOW_TEXT}${BOLD_TEXT}🤔 Default region could not be auto-detected.${RESET_FORMAT}"
  if [ -n "$ZONE" ]; then
    echo "${BLUE_TEXT}${BOLD_TEXT}⚙️ Trying to derive region from the provided zone: $ZONE${RESET_FORMAT}"
    REGION="${ZONE%-*}"
    if [ -z "$REGION" ] || [ "$REGION" == "$ZONE" ]; then
        echo "${RED_TEXT}${BOLD_TEXT}❌ Failed to derive region from zone. Region remains unknown.${RESET_FORMAT}"
    else
        echo "${GREEN_TEXT}${BOLD_TEXT}👍 Region derived as: $REGION${RESET_FORMAT}"
    fi
  else
    echo "${RED_TEXT}${BOLD_TEXT}⚠️ Zone is not set, so region cannot be derived automatically.${RESET_FORMAT}"
  fi
fi

if [ -z "$REGION" ]; then
  echo "${YELLOW_TEXT}${BOLD_TEXT}🤔 Region still undetermined. Manual input required.${RESET_FORMAT}"
  while [ -z "$REGION" ]; do
    read -p "${WHITE_TEXT}${BOLD_TEXT}⌨️ Please enter the REGION: ${RESET_FORMAT}" REGION
    if [ -z "$REGION" ]; then
      echo "${RED_TEXT}${BOLD_TEXT}🚫 Region cannot be empty. Please provide a valid region.${RESET_FORMAT}"
    fi
  done
fi

export REGION
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Region set to: $REGION${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🆔 Fetching your Google Cloud Project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Project ID identified as: $PROJECT_ID${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️ Configuring default compute region to $REGION...${RESET_FORMAT}"
gcloud config set compute/region $REGION
echo "${GREEN_TEXT}${BOLD_TEXT}👍 Default compute region configured.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🛠️ Enabling necessary Google Cloud services. This might take a moment...${RESET_FORMAT}"
gcloud services enable \
container.googleapis.com \
clouddeploy.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com \
clouddeploy.googleapis.com
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Services enabled. Allowing changes to propagate...${RESET_FORMAT}"
for i in $(seq 30 -1 1); do
  echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ $i seconds remaining... ${RESET_FORMAT}"
  sleep 1
done
echo -e "\r${GREEN_TEXT}${BOLD_TEXT}⏳ Propagation time complete. ${RESET_FORMAT}"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}🏗️ Initiating creation of GKE clusters (test, staging, prod) asynchronously...${RESET_FORMAT}"
gcloud container clusters create test --node-locations=$ZONE --num-nodes=1  --async
gcloud container clusters create staging --node-locations=$ZONE --num-nodes=1  --async
gcloud container clusters create prod --node-locations=$ZONE --num-nodes=1  --async
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📋 Displaying initial list of GKE clusters and their statuses...${RESET_FORMAT}"
gcloud container clusters list --format="csv(name,status)"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📦 Creating Artifact Registry repository 'web-app' for Docker images...${RESET_FORMAT}"
gcloud artifacts repositories create web-app \
--description="Image registry for tutorial web app" \
--repository-format=docker \
--location=$REGION
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Artifact Registry repository created.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🚚 Preparing project files: Navigating to home, cloning repository, and checking out specific version...${RESET_FORMAT}"
cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Project files prepared.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📝 Generating Skaffold configuration from template...${RESET_FORMAT}"
envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml


if grep -q "{{project-id}}" web/skaffold.yaml; then
  echo "${YELLOW_TEXT}${BOLD_TEXT}⚠️ Detected '{{project-id}}' placeholder in skaffold.yaml. Attempting substitution...${RESET_FORMAT}"
  cp web/skaffold.yaml web/skaffold.yaml.bak
  sed -i "s/{{project-id}}/$PROJECT_ID/g" web/skaffold.yaml
  echo "${GREEN_TEXT}${BOLD_TEXT}✅ Placeholder substitution complete.${RESET_FORMAT}"
fi

echo "${GREEN_TEXT}${BOLD_TEXT}✅ Skaffold configuration generated. Displaying content:${RESET_FORMAT}"
cat web/skaffold.yaml
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🛠️ Ensuring Cloud Build GCS bucket (gs://${PROJECT_ID}_cloudbuild) exists...${RESET_FORMAT}"
# Check if the bucket already exists
if ! gsutil ls "gs://${PROJECT_ID}_cloudbuild/" &>/dev/null; then
  echo "${YELLOW_TEXT}${BOLD_TEXT}Bucket gs://${PROJECT_ID}_cloudbuild/ not found. Attempting to create in region ${REGION}...${RESET_FORMAT}"
  # Create the bucket. Using -l for region. -b on for uniform bucket-level access is good practice.
  if gsutil mb -p "${PROJECT_ID}" -l "${REGION}" -b on "gs://${PROJECT_ID}_cloudbuild/"; then
    echo "${GREEN_TEXT}${BOLD_TEXT}✅ Bucket gs://${PROJECT_ID}_cloudbuild/ created successfully.${RESET_FORMAT}"
    # Add a small delay for bucket creation to propagate if it was just created.
    sleep 5
  else
    echo "${RED_TEXT}${BOLD_TEXT}❌ Failed to create bucket gs://${PROJECT_ID}_cloudbuild/.${RESET_FORMAT}"
    echo "${RED_TEXT}${BOLD_TEXT}This may cause the Skaffold build to fail. Please check permissions or create it manually.${RESET_FORMAT}"
  fi
else
  echo "${GREEN_TEXT}${BOLD_TEXT}✅ Bucket gs://${PROJECT_ID}_cloudbuild/ already exists.${RESET_FORMAT}"
fi
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🧱 Building the application using Skaffold. This may take some time...${RESET_FORMAT}"
cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$PROJECT_ID/web-app \
--file-output artifacts.json
cd ..
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Application build complete. Artifacts metadata saved to artifacts.json.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}ℹ️ Using 'web/artifacts.json' directly for Cloud Deploy release.${RESET_FORMAT}"
# The jq transformation of artifacts.json to transformed_artifacts.json has been removed.
# The original web/artifacts.json produced by 'skaffold build' contains the
# {"builds":[{"imageName":"...","tag":"..."}]} structure, which is expected by
# Cloud Deploy when Skaffold is used for rendering manifests.
# This approach avoids potential 'KeyError: tag' issues during 'gcloud deploy releases create'.

# Verify web/artifacts.json exists
if [ ! -f web/artifacts.json ]; then
    echo "${RED_TEXT}${BOLD_TEXT}❌ Error: web/artifacts.json not found. 'skaffold build' might have failed or did not produce the artifact list. Cannot proceed with release creation.${RESET_FORMAT}"
    # exit 1 # Consider exiting if this is a critical failure
fi
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Proceeding with web/artifacts.json for the release.${RESET_FORMAT}"
# Optional: Display content of artifacts.json for verification
# echo "Using artifacts content from web/artifacts.json:"
# cat web/artifacts.json
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🖼️ Listing Docker images in the Artifact Registry repository...${RESET_FORMAT}"
gcloud artifacts docker images list \
$REGION-docker.pkg.dev/$PROJECT_ID/web-app \
--include-tags \
--format yaml
echo

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️ Configuring default Cloud Deploy region to $REGION...${RESET_FORMAT}"
gcloud config set deploy/region $REGION
echo "${GREEN_TEXT}${BOLD_TEXT}👍 Cloud Deploy region configured.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📜 Setting up the Cloud Deploy delivery pipeline by copying and applying configuration...${RESET_FORMAT}"
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Delivery pipeline configuration applied.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📄 Describing the 'web-app' delivery pipeline details...${RESET_FORMAT}"
gcloud beta deploy delivery-pipelines describe web-app
echo

echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Monitoring GKE cluster statuses. Waiting for all clusters to be in 'RUNNING' state...${RESET_FORMAT}"
while true; do
  cluster_statuses=$(gcloud container clusters list --format="csv(name,status)" | tail -n +2)
  all_running=true # Reset for each iteration of the outer loop

  if [ -z "$cluster_statuses" ]; then
    echo "${YELLOW_TEXT}${BOLD_TEXT}🤔 No clusters found by gcloud list yet. Will retry.${RESET_FORMAT}"
    all_running=false
  else
    echo "${YELLOW_TEXT}${BOLD_TEXT}🔄 Checking cluster statuses...${RESET_FORMAT}"
    # Correctly pipe cluster_statuses to the inner loop
    echo "$cluster_statuses" | while IFS=, read -r cluster_name cluster_status; do
      # Trim whitespace which can affect comparisons
      cluster_name_trimmed=$(echo "$cluster_name" | tr -d '[:space:]')
      cluster_status_trimmed=$(echo "$cluster_status" | tr -d '[:space:]')

      if [ -z "$cluster_name_trimmed" ]; then # Skip empty lines that might result from gcloud output processing
          continue
      fi

      echo "${CYAN_TEXT}Cluster: ${cluster_name_trimmed}, Status: ${cluster_status_trimmed}${RESET_FORMAT}"
      if [[ "$cluster_status_trimmed" != "RUNNING" ]]; then
        all_running=false
      fi
    done
  fi

  if [ "$all_running" = true ] && [ -n "$cluster_statuses" ]; then
    echo "${GREEN_TEXT}${BOLD_TEXT}✅ All detected GKE clusters are RUNNING.${RESET_FORMAT}"
    break 
  fi
  
  echo "${YELLOW_TEXT}${BOLD_TEXT}🕒 Not all clusters are RUNNING yet or no clusters detected. Re-checking in 10 seconds...${RESET_FORMAT}"
  for i in $(seq 10 -1 1); do
    echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ $i seconds remaining before next check... ${RESET_FORMAT}"
    sleep 1
  done
  echo -e "\r${YELLOW_TEXT}${BOLD_TEXT}⏳ Re-checking now...                               ${RESET_FORMAT}" 
done 
echo 

echo "${BLUE_TEXT}${BOLD_TEXT}🔑 Fetching GKE cluster credentials and renaming kubectl contexts for easier access...${RESET_FORMAT}"
CONTEXTS=("test" "staging" "prod")
for CONTEXT in ${CONTEXTS[@]}
do
    echo "${CYAN_TEXT}${BOLD_TEXT}Processing context: ${CONTEXT}...${RESET_FORMAT}"
    gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
    kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Credentials fetched and contexts renamed.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🏠 Applying Kubernetes namespace 'web-app' to all contexts...${RESET_FORMAT}"
for CONTEXT_NAME in ${CONTEXTS[@]} 
do
    echo "${CYAN_TEXT}${BOLD_TEXT}Applying namespace to context: ${CONTEXT_NAME}...${RESET_FORMAT}"
    MAX_RETRIES=20
    RETRY_COUNT=0
    SUCCESS=false
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if kubectl --context ${CONTEXT_NAME} apply -f kubernetes-config/web-app-namespace.yaml; then
            echo "${GREEN_TEXT}${BOLD_TEXT}✅ Namespace applied to ${CONTEXT_NAME} successfully.${RESET_FORMAT}"
            SUCCESS=true
            break
        else
            RETRY_COUNT=$((RETRY_COUNT+1))
            echo "${YELLOW_TEXT}${BOLD_TEXT}⚠️ Failed to apply namespace to ${CONTEXT_NAME} (attempt ${RETRY_COUNT}/${MAX_RETRIES}). Will retry after delay.${RESET_FORMAT}"
            
            RETRY_WAIT_SECONDS=5
            for i in $(seq $RETRY_WAIT_SECONDS -1 1); do
          echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ $i seconds remaining...                                 ${RESET_FORMAT}"
          sleep 1
            done
            echo -e "\r${YELLOW_TEXT}${BOLD_TEXT}⏳ Retrying now...                                               ${RESET_FORMAT}"
        fi
    done
    if [ "$SUCCESS" != true ]; then
        echo "${RED_TEXT}${BOLD_TEXT}❌ Failed to apply namespace to ${CONTEXT_NAME} after ${MAX_RETRIES} attempts. This might cause subsequent steps to fail.${RESET_FORMAT}"
    fi
done
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Namespace application process completed for all contexts.${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🎯 Configuring Cloud Deploy targets for each context...${RESET_FORMAT}"
for CONTEXT in ${CONTEXTS[@]}
do
    echo "${CYAN_TEXT}${BOLD_TEXT}Processing target: ${CONTEXT}...${RESET_FORMAT}"
    envsubst < clouddeploy-config/target-$CONTEXT.yaml.template > clouddeploy-config/target-$CONTEXT.yaml
    gcloud beta deploy apply --file=clouddeploy-config/target-$CONTEXT.yaml --region=${REGION} --project=${PROJECT_ID}
done
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Cloud Deploy targets configured and applied.${RESET_FORMAT}"
echo
echo
sleep 10

echo
echo "${BLUE_TEXT}${BOLD_TEXT}🚀 Creating Cloud Deploy release 'web-app-001'...${RESET_FORMAT}"
gcloud beta deploy releases create web-app-001 \
  --delivery-pipeline web-app \
  --build-artifacts web/artifacts.json \
  --source web/ \
  --project=${PROJECT_ID} \
  --region=${REGION}

RELEASE_CREATION_STATUS=$?

if [ $RELEASE_CREATION_STATUS -eq 0 ]; then
  echo "${GREEN_TEXT}${BOLD_TEXT}✅ Release 'web-app-001' creation initiated successfully.${RESET_FORMAT}"
  echo "${BLUE_TEXT}${BOLD_TEXT}Cloud Deploy will now automatically roll out this release to the first target ('test').${RESET_FORMAT}"
else
  echo "${RED_TEXT}${BOLD_TEXT}❌ Failed to create Cloud Deploy release 'web-app-001' (Exit Code: $RELEASE_CREATION_STATUS).${RESET_FORMAT}"
  echo "${RED_TEXT}${BOLD_TEXT}Please check the gcloud logs above for details. Aborting further deployment steps.${RESET_FORMAT}"
  exit 1 # Exit if release creation fails, as subsequent steps depend on it.
fi
echo

test_rollout_succeeded=false
echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Waiting for the initial rollout to 'test' target to complete...${RESET_FORMAT}"
while true; do
  status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --filter="targetId=test" --format="value(state)" | head -n 1)

  if [ "$status" == "SUCCEEDED" ]; then
    echo -e "\r${GREEN_TEXT}${BOLD_TEXT}🎉 Rollout to 'test' SUCCEEDED!                                        ${RESET_FORMAT}"
    test_rollout_succeeded=true
    break
  elif [[ "$status" == "FAILED" || "$status" == "CANCELLED" || "$status" == "HALTED" ]]; then
    echo -e "\r${RED_TEXT}${BOLD_TEXT}❌ Rollout to 'test' is ${status}. Please check logs.                 ${RESET_FORMAT}"
    test_rollout_succeeded=false
    break
  fi

  current_status_display=${status:-"UNKNOWN"}
  WAIT_DURATION=10
  for i in $(seq $WAIT_DURATION -1 1); do
    echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ 'Test' rollout status: ${current_status_display}. $i seconds remaining... ${RESET_FORMAT}            "
    sleep 1
  done
  echo -ne "\r${YELLOW_TEXT}${BOLD_TEXT}⏳ 'Test' rollout status: ${current_status_display}. Re-checking now... ${RESET_FORMAT}            "
done
echo

if [ "$test_rollout_succeeded" = true ]; then
  echo "${BLUE_TEXT}${BOLD_TEXT}🔬 Switching to 'test' Kubernetes context and verifying deployed resources...${RESET_FORMAT}"
  kubectx test
  kubectl get all -n web-app
  echo

  echo "${BLUE_TEXT}${BOLD_TEXT}➡️ Promoting release 'web-app-001' to the 'staging' target...${RESET_FORMAT}"
  gcloud beta deploy releases promote \
  --delivery-pipeline web-app \
  --release web-app-001 \
  --quiet
  echo
  staging_rollout_succeeded=false
  echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Waiting for the rollout to 'staging' target to complete...${RESET_FORMAT}"
  while true; do
    status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --filter="targetId=staging" --format="value(state)" | head -n 1)

    if [ "$status" == "SUCCEEDED" ]; then
      echo -e "\r${GREEN_TEXT}${BOLD_TEXT}🎉 Rollout to 'staging' SUCCEEDED!                                        ${RESET_FORMAT}"
      staging_rollout_succeeded=true
      break
    elif [[ "$status" == "FAILED" || "$status" == "CANCELLED" || "$status" == "HALTED" ]]; then
      echo -e "\r${RED_TEXT}${BOLD_TEXT}❌ Rollout to 'staging' is ${status}. Please check logs.                 ${RESET_FORMAT}"
      staging_rollout_succeeded=false
      break
    fi

    current_status_display=${status:-"UNKNOWN"}
    WAIT_DURATION=10
    for i in $(seq $WAIT_DURATION -1 1); do
      echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ 'Staging' rollout status: ${current_status_display}. $i seconds remaining... ${RESET_FORMAT}            "
      sleep 1
    done
    echo -ne "\r${YELLOW_TEXT}${BOLD_TEXT}⏳ 'Staging' rollout status: ${current_status_display}. Re-checking now... ${RESET_FORMAT}            "
  done
  echo

  if [ "$staging_rollout_succeeded" = true ]; then
    echo "${BLUE_TEXT}${BOLD_TEXT}➡️ Promoting release 'web-app-001' to the 'prod' target (this will require approval)...${RESET_FORMAT}"
    gcloud beta deploy releases promote \
    --delivery-pipeline web-app \
    --release web-app-001 \
    --quiet
    echo

    prod_rollout_pending_approval=false # Initialize correctly
    echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Waiting for the rollout to 'prod' to reach 'PENDING_APPROVAL' state...${RESET_FORMAT}"
    while true; do
      status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --filter="targetId=prod" --format="value(state)" | head -n 1) # Corrected filter to targetId

      if [ "$status" == "PENDING_APPROVAL" ]; then
        echo -e "\r${GREEN_TEXT}${BOLD_TEXT}👍 Rollout to 'prod' is now PENDING_APPROVAL!                                 ${RESET_FORMAT}"
        prod_rollout_pending_approval=true # Set to true when condition met
        break
      elif [[ "$status" == "FAILED" || "$status" == "CANCELLED" || "$status" == "HALTED" || "$status" == "SUCCEEDED" ]]; then
        echo -e "\r${RED_TEXT}${BOLD_TEXT}❌ Rollout to 'prod' is ${status} instead of PENDING_APPROVAL. Please check logs. ${RESET_FORMAT}"
        prod_rollout_pending_approval=false
        break
      fi

      current_status_display=${status:-"UNKNOWN"}
      WAIT_DURATION=10
      for i in $(seq $WAIT_DURATION -1 1); do
        echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ 'Prod' rollout status: ${current_status_display}. Waiting for PENDING_APPROVAL. $i seconds remaining... ${RESET_FORMAT}            "
        sleep 1
      done
      echo -ne "\r${YELLOW_TEXT}${BOLD_TEXT}⏳ 'Prod' rollout status: ${current_status_display}. Re-checking now...                                           ${RESET_FORMAT}"
    done
    echo

    if [ "$prod_rollout_pending_approval" = true ]; then
      prod_rollout_name=$(gcloud beta deploy rollouts list \
        --delivery-pipeline web-app \
        --release web-app-001 \
        --filter="targetId=prod AND state=PENDING_APPROVAL" \
        --format="value(name)" | head -n 1)

      if [ -n "$prod_rollout_name" ]; then
        echo "${BLUE_TEXT}${BOLD_TEXT}✅ Approving rollout '$prod_rollout_name' for 'prod' target...${RESET_FORMAT}" # Added approval message
        gcloud beta deploy rollouts approve "$prod_rollout_name" \
        --delivery-pipeline web-app \
        --release web-app-001 \
        --quiet
        echo

        prod_rollout_succeeded=false # Initialize correctly
        echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Waiting for the rollout to 'prod' target to complete after approval...${RESET_FORMAT}"
        while true; do
          status=$(gcloud beta deploy rollouts list --delivery-pipeline web-app --release web-app-001 --filter="targetId=prod" --format="value(state)" | head -n 1) # Corrected filter to targetId

          if [ "$status" == "SUCCEEDED" ]; then
            echo -e "\r${GREEN_TEXT}${BOLD_TEXT}🎉 Rollout to 'prod' SUCCEEDED!                                        ${RESET_FORMAT}"
            prod_rollout_succeeded=true # Set to true on success
            break
          elif [[ "$status" == "FAILED" || "$status" == "CANCELLED" || "$status" == "HALTED" ]]; then
            echo -e "\r${RED_TEXT}${BOLD_TEXT}❌ Rollout to 'prod' is ${status}. Please check logs.                 ${RESET_FORMAT}"
            prod_rollout_succeeded=false
            break
          fi

          current_status_display=${status:-"UNKNOWN"}
          WAIT_DURATION=10
          for i in $(seq $WAIT_DURATION -1 1); do
            echo -ne "${YELLOW_TEXT}${BOLD_TEXT}\r⏳ 'Prod' rollout status: ${current_status_display}. $i seconds remaining... ${RESET_FORMAT}            "
            sleep 1
          done
          echo -ne "\r${YELLOW_TEXT}${BOLD_TEXT}⏳ 'Prod' rollout status: ${current_status_display}. Re-checking now... ${RESET_FORMAT}            "
        done
        echo

        if [ "$prod_rollout_succeeded" = true ]; then
          echo "${BLUE_TEXT}${BOLD_TEXT}🔬 Switching to 'prod' Kubernetes context and verifying deployed resources...${RESET_FORMAT}"
          kubectx prod
          kubectl get all -n web-app
        else
          echo "${RED_TEXT}${BOLD_TEXT}❌ Prod rollout failed after approval. Skipping final verification.${RESET_FORMAT}"
        fi
      else
        echo "${RED_TEXT}${BOLD_TEXT}❌ Could not find a 'prod' rollout in PENDING_APPROVAL state to approve.${RESET_FORMAT}"
      fi
    else
      echo "${RED_TEXT}${BOLD_TEXT}❌ Prod rollout did not reach PENDING_APPROVAL state. Skipping approval and final rollout monitoring.${RESET_FORMAT}"
    fi
  else
    echo "${RED_TEXT}${BOLD_TEXT}❌ Staging rollout failed. Skipping promotion to prod and subsequent steps.${RESET_FORMAT}"
  fi
else
  echo "${RED_TEXT}${BOLD_TEXT}❌ Test rollout failed. Skipping promotion to staging, prod, and subsequent steps.${RESET_FORMAT}"
fi
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🔬 Switching to 'prod' Kubernetes context and verifying deployed resources...${RESET_FORMAT}"
kubectx prod
kubectl get all -n web-app
echo

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 Enjoyed the video? Consider subscribing to SparkWave 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwave.01${RESET_FORMAT}"
echo

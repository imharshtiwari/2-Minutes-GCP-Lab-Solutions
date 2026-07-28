#!/bin/bash

# =========================
# COLOR & FORMAT VARIABLES
# =========================
RED_TEXT=$'\033[0;91m'
BLUE_TEXT=$'\033[0;94m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'

clear

# =========================
# WELCOME MESSAGE
# =========================
echo "${BLUE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}     ✨✨ GOOGLE CLOUD LAB AUTOMATION | SPARKWAVE DEV ✨✨       ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

# Prompt user for Zone
echo "${RED_TEXT}${BOLD_TEXT}[Action Required] Please enter your target GCP Zone (e.g., us-central1-a):${RESET_FORMAT}"
read -r ZONE
export ZONE

echo "${BLUE_TEXT}${BOLD_TEXT}[Step 1/9] Provisioning a new e2-small VM instance (lamp-1-vm)${RESET_FORMAT}"

# Create the instance with the necessary metadata and tags
gcloud compute instances create lamp-1-vm \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=lamp-1-vm,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240709,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

echo "${RED_TEXT}${BOLD_TEXT}[Step 2/9] Configuring firewall rules to allow incoming HTTP traffic${RESET_FORMAT}"

gcloud compute firewall-rules create allow-http \
    --project=$DEVSHELL_PROJECT_ID \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

sleep 10

echo "${BLUE_TEXT}${BOLD_TEXT}[Step 3/9] Generating SSH keys for secure access${RESET_FORMAT}"

gcloud compute config-ssh --project "$DEVSHELL_PROJECT_ID" --quiet

echo "${RED_TEXT}${BOLD_TEXT}[Step 4/9] Bootstrapping VM with Apache2 and PHP...${RESET_FORMAT}"

gcloud compute ssh lamp-1-vm --project "$DEVSHELL_PROJECT_ID" --zone $ZONE --command "sudo sed -i '/buster-backports/d' /etc/apt/sources.list && sudo apt-get update && sudo apt-get install apache2 php7.3 -y && sudo service apache2 restart"

sleep 10

echo "${BLUE_TEXT}${BOLD_TEXT}[Step 5/9] Retrieving the Instance ID for monitoring setup.${RESET_FORMAT}"

INSTANCE_ID="$(gcloud compute instances describe lamp-1-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --format='value(id)')"

echo "${RED_TEXT}${BOLD_TEXT}[Step 6/9] Initializing Google Cloud Uptime Monitoring...${RESET_FORMAT}"

gcloud monitoring uptime create lamp-uptime-check \
  --resource-type="gce-instance" \
  --resource-labels=project_id=$DEVSHELL_PROJECT_ID,instance_id=$INSTANCE_ID,zone=$ZONE

echo "${BLUE_TEXT}${BOLD_TEXT}[Step 7/9] Setting up email notification channels.${RESET_FORMAT}"

cat > email-channel.json <<EOF_END
{
  "type": "email",
  "displayName": "kenilithcloudx",
  "description": "kenilithcloudx",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF_END

gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"

echo "${RED_TEXT}${BOLD_TEXT}[Step 8/9] Extracting notification channel ID${RESET_FORMAT}"

channel_info=$(gcloud beta monitoring channels list)
channel_id=$(echo "$channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

echo "${BLUE_TEXT}${BOLD_TEXT}[Step 9/9] Deploying inbound network traffic alert policies.${RESET_FORMAT}"

cat > app-engine-error-percent-policy.json <<EOF_END
{
  "displayName": "Inbound Traffic Alert",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - Network traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/interface/traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "60s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 500
      }
    }
  ],
  "alertStrategy": {},
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$channel_id"
  ],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_END

gcloud alpha monitoring policies create --policy-from-file="app-engine-error-percent-policy.json"

# =========================
# COMPLETION FOOTER
# =========================
echo
echo "${RED_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}                   LAB EXECUTION COMPLETE!                  ${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}      ✨✨✨     SUBSCRIBE to SPARKWAVE DEV    ✨✨✨         ${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}🙏 Thank you for using the SPARKWAVE DEV automated setup.${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}📢 For more tutorials and Google Cloud Labs, visit:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@sparkwavedev${RESET_FORMAT}"
echo

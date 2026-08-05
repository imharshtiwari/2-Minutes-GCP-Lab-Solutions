# Monitoring in Google Cloud: Challenge Lab || [ARC115](https://www.skills.google/catalog_lab/6446) ||

## 🔑 Solution [here](https://youtu.be/L3Q8sE0dkUQ)

### ⚙️ Execute the Following Commands in Cloud Shell
```
GREEN='\e[1;32m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
RESET='\e[0m'
BOLD='\e[1m'

clear
echo -e "${CYAN}${BOLD}>>> SPARKWAVE  DEV ✨: ARC115 ZERO-UI AUTOMATION (FINAL) <<<${RESET}\n"

# ------------------------------------------------------------------
# Initialization & VM Discovery
# ------------------------------------------------------------------
export PROJECT_ID=$(gcloud config get-value project)
export USER_EMAIL=$(gcloud config get-value account)
export INSTANCE_NAME=$(gcloud compute instances list --format="value(name)" --limit=1)
export ZONE=$(gcloud compute instances list --format="value(zone)" --limit=1)
export VM_EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo -e "${BLUE}${BOLD}[*] Target Instance: $INSTANCE_NAME in $ZONE${RESET}"
echo -e "${BLUE}${BOLD}[*] External IP: $VM_EXTERNAL_IP${RESET}\n"

# ------------------------------------------------------------------
# Task 1: Install & Configure the Modern Ops Agent
# ------------------------------------------------------------------
echo -e "${YELLOW}${BOLD}[SPARKWAVE  DEV ✨] Step 1: Installing & Configuring Ops Agent...${RESET}"

cat << 'EOF' > setup_agents.sh
#!/bin/bash
# 1. Install the modern Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# 2. Safely configure Apache + Hostmetrics (Fixes the missing CPU load metric!)
cat << 'YAMLEOF' | sudo tee /etc/google-cloud-ops-agent/config.yaml
logging:
  receivers:
    syslog:
      type: files
      include_paths:
      - /var/log/messages
      - /var/log/syslog
    apache_access:
      type: apache_access
    apache_error:
      type: apache_error
  service:
    pipelines:
      default_pipeline:
        receivers: [syslog]
      apache_pipeline:
        receivers: [apache_access, apache_error]
metrics:
  receivers:
    hostmetrics:
      type: hostmetrics
      collection_interval: 60s
    apache:
      type: apache
  service:
    pipelines:
      default_pipeline:
        receivers: [hostmetrics]
      apache_pipeline:
        receivers: [apache]
YAMLEOF

# 3. Restart the agent to apply changes
sudo systemctl restart google-cloud-ops-agent

# 4. Generate Background Traffic for Task 3 Alert Policy Trigger
timeout 120 bash -c -- 'while true; do curl localhost | grep -oP "<title>.*</title>"; sleep .1s;done ' > /dev/null 2>&1 &
EOF

gcloud compute scp setup_agents.sh $INSTANCE_NAME:/tmp --zone=$ZONE --quiet
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --quiet --command="bash /tmp/setup_agents.sh"

echo -e "${GREEN}${BOLD}✓ Ops Agent installed and background traffic generated!${RESET}\n"

# ------------------------------------------------------------------
# Task 2: Create Uptime Check
# ------------------------------------------------------------------
echo -e "${CYAN}${BOLD}[SPARKWAVE  DEV ✨] Step 2: Creating Uptime Check...${RESET}"
gcloud monitoring uptime create "SPARKWAVE DEV Uptime" \
  --resource-type=uptime-url \
  --resource-labels=host=$VM_EXTERNAL_IP,path=/,port=80 > /dev/null 2>&1

echo -e "${GREEN}${BOLD}✓ Uptime Check active!${RESET}\n"

# ------------------------------------------------------------------
# Task 3: Notification Channel & Alert Policy
# ------------------------------------------------------------------
echo -e "${MAGENTA}${BOLD}[SPARKWAVE  DEV ✨] Step 3: Configuring Alert Policy...${RESET}"

cat > email-channel.json <<EOF
{
  "type": "email",
  "displayName": "SPARKWAVE DEV Alert",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF

gcloud beta monitoring channels create --channel-content-from-file=email-channel.json > /dev/null 2>&1
export CHANNEL_ID=$(gcloud beta monitoring channels list --format="value(name)" --limit=1)

cat > alert-policy.json <<EOF
{
  "displayName": "SPARKWAVE DEV Traffic Alert",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - Traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/apache.traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 3072
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "1800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$CHANNEL_ID"
  ],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF

gcloud alpha monitoring policies create --policy-from-file="alert-policy.json" > /dev/null 2>&1

echo -e "${GREEN}${BOLD}✓ Alert Policy deployed!${RESET}\n"

# ------------------------------------------------------------------
# Task 5: Log-Based Metric
# ------------------------------------------------------------------
echo -e "${BLUE}${BOLD}[SPARKWAVE  DEV ✨] Step 4: Creating Log-Based Metric...${RESET}"

gcloud logging metrics create apache_requests \
  --description="Count Apache 200 OK responses" \
  --log-filter="resource.type=\"gce_instance\" logName=\"projects/$PROJECT_ID/logs/apache-access\" textPayload:\"200\"" > /dev/null 2>&1

echo -e "${GREEN}${BOLD}✓ Log-based metric created!${RESET}\n"

# Cleanup
rm setup_agents.sh email-channel.json alert-policy.json

echo -e "${YELLOW}${BOLD}>>> SCRIPT COMPLETE! Please execute the manual UI stepsb for Task 4. - Follow the video instructions <<<${RESET}"
```
## Task 4 - `Create a Dashboard and Charts`

1. In the Google Cloud Console search bar, search for `Monitoring`
2. then click on Monitoring → `Dashboards`
3. Click: `+ CREATE DASHBOARD`
4. Set the dashboard name exactly as follows: `Sparkwave Dev`
   
### 📈 Chart 1- CPU Load

1. Click: `+ ADD WIDGET`
2. Select: `Line Chart`
3. Under Metric:
   
  | Setting      |Value          |
  | -----------  |  ----------   |
  | Resource Type| VM Instance   | 
  | Metric       | CPU load (1m) |
  
4. Click: `Apply`

### 📈 Chart 2 — Apache Requests

1. Click: `+ ADD WIDGET`
2. Select: `Line Chart`
3. Under Metric:
      
  | Setting      |Value          |
  | -----------  |  ----------   |
  | Resource Type| VM Instance   | 
  | Metric       | Requests (Apache) |
  
4. Click: `Apply`

   
   

# 🎉 🐻‍❄️ྀིྀི 🐻‍❄️ྀིྀི Yeeeeaaahhh! You Did It! 🎉


Keep pushing forward—every small step takes you closer to your dream.! 💻🚀

You've successfully completed the lab. **Miles to go!** 🚀


### 💬 Stay Connected with Our Community!

👉 Join the conversation and never miss an update:

💚 [𝗪𝗵𝗮𝘁𝘀𝗔𝗽𝗽 𝗖𝗼𝗺𝗺𝘂𝗻𝗶𝘁𝘆](https://chat.whatsapp.com/)
📢 [Telegram Channel](https://t.me/sparkwave.01)
👥 [Discussion Group](https://t.me/sparkwave.01chats)

# ✨[SPARKWAVE DEV](https://www.youtube.com/@sparkwavedev)

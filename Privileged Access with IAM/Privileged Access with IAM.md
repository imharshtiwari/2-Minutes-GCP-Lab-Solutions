# Privileged Access with IAM || [GSP526](https://www.skills.google/catalog_lab/32313) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwavedev)

> [!IMPORTANT] 
> This is an independent, community-made walkthrough created to help you understand why each step works. Attempt the challenge yourself first. This guide is provided for educational purposes and is not intended to replace the official lab instructions or your own hands-on learning. It is not affiliated with or endorsed by Google Cloud or Google Cloud Skills Boost. Always follow the official Google Cloud and Qwiklabs terms of service, lab instructions, and usage policies.


## ⚙️ Exectue this in Cloud Shell

```
#!/bin/bash

GREEN='\e[1;32m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
WHITE='\e[1;37m'
RESET='\e[0m'
BOLD='\e[1m'

clear

echo -e "${CYAN}${BOLD}"

cat << "EOF"

 ███████╗██████╗  █████╗ ██████╗ ██╗  ██╗██╗    ██╗ █████╗ ██╗   ██╗███████╗
 ██╔════╝██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██║    ██║██╔══██╗██║   ██║██╔════╝
 ███████╗██████╔╝███████║██████╔╝█████╔╝ ██║ █╗ ██║███████║██║   ██║█████╗
 ╚════██║██╔═══╝ ██╔══██║██╔══██╗██╔═██╗ ██║███╗██║██╔══██║╚██╗ ██╔╝██╔══╝
 ███████║██║     ██║  ██║██║  ██║██║  ██╗╚███╔███╔╝██║  ██║ ╚████╔╝ ███████╗
 ╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝

                                ██████╗ ███████╗██╗   ██╗
                                ██╔══██╗██╔════╝██║   ██║
                                ██║  ██║█████╗  ██║   ██║
                                ██║  ██║██╔══╝  ╚██╗ ██╔╝
                                ██████╔╝███████╗ ╚████╔╝
                                ╚═════╝ ╚══════╝  ╚═══╝

EOF

echo -e "${RESET}"

echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}${BOLD}║   🌊 WELCOME TO SPARKWAVE  DEV ✨                               ║${RESET}"
echo -e "${BLUE}${BOLD}║   🚀 TARGET:  Privileged Access with IAM || GSP526              ║${RESET}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"

export PROJECT_ID=$(gcloud config get-value project)

echo "Enabling Privileged Access Manager API..."
gcloud services enable privilegedaccessmanager.googleapis.com

echo "Assigning IAM Role to the PAM Service Agent..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
PAM_SA="service-${PROJECT_NUMBER}@gcp-sa-pam.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${PAM_SA}" \
    --role="roles/privilegedaccessmanager.serviceAgent"


echo -e "\n${MAGENTA}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAGENTA}${BOLD}║           🎉 LAB COMPLETED SUCCESSFULLY 🎉                  ║${RESET}"
echo -e "${MAGENTA}${BOLD}╚========== ✨✨ SUBSCRIBE TO SPARKWAVE DEV ✨✨=============${RESET}"
echo -e "${MAGENTA}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo -e "${CYAN}${BOLD}⚠️ Subscribe to SparkWaveDev for more videos https://www.youtube.com/sparkwavedev ⚠️${RESET}\n"

```

### 🐼 Congratulations 🎉 for completing the Challenge Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# ✨✨[SPARKWAVE DEV](https://www.youtube.com/@sparkwavedev) ✨✨

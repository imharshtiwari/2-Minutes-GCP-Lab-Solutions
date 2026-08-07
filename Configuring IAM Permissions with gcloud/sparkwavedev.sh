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
echo -e "${BLUE}${BOLD}║   🚀 TARGET:  Configuring IAM Permissions with gcloud | GSP647  ║${RESET}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"



# =========================
# WELCOME MESSAGE
# =========================
echo "${BLUE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}              🚀 GOOGLE CLOUD LAB | SPARKWAVE  DEV ✨ 🚀            ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}INITIATING CLOUD CONFIGURATION...${RESET_FORMAT}"
echo

echo "${RED_TEXT}${BOLD_TEXT}Authenticating Google Cloud account...${RESET_FORMAT}"
gcloud auth login --quiet

echo "${BLUE_TEXT}${BOLD_TEXT}Determining default Compute Zone and Region...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo "${BLUE_TEXT}Default Zone: ${ZONE}${RESET_FORMAT}"
echo "${BLUE_TEXT}Default Region: ${REGION}${RESET_FORMAT}"

echo "${BLUE_TEXT}${BOLD_TEXT}Configuring gcloud compute settings...${RESET_FORMAT}"
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

echo "${RED_TEXT}${BOLD_TEXT}Creating VM instance lab-1...${RESET_FORMAT}"
gcloud compute instances create lab-1 --zone $ZONE --machine-type=e2-standard-2

echo "${BLUE_TEXT}${BOLD_TEXT}Selecting alternative zone in ${REGION}...${RESET_FORMAT}"
export NEWZONE=$(gcloud compute zones list --filter="name~'^$REGION'" \
  --format="value(name)" | grep -v "^$ZONE$" | head -n 1)
echo "${BLUE_TEXT}New Zone: ${NEWZONE}${RESET_FORMAT}"

echo "${RED_TEXT}${BOLD_TEXT}Updating to new zone: ${NEWZONE}...${RESET_FORMAT}"
gcloud config set compute/zone $NEWZONE

# Function to prompt user to check progress
function check_progress {
    while true; do
        echo
        echo -n "${RED_TEXT}${BOLD_TEXT}Have you checked Task 1 progress? (Y/N): ${RESET_FORMAT}"
        read -r user_input
        case $user_input in
            [Yy]* ) 
                echo
                echo "${BLUE_TEXT}${BOLD_TEXT}Continuing with next steps...${RESET_FORMAT}"
                echo
                break
                ;;
            [Nn]* )
                echo
                echo "${RED_TEXT}${BOLD_TEXT}Please check Task 1 first${RESET_FORMAT}"
                ;;
            * )
                echo
                echo "${RED_TEXT}${BOLD_TEXT}Please enter Y or N${RESET_FORMAT}"
                ;;
        esac
    done
}


check_progress

echo "${BLUE_TEXT}${BOLD_TEXT}Creating user2 configuration...${RESET_FORMAT}"
gcloud config configurations create user2 --quiet

echo "${RED_TEXT}${BOLD_TEXT}Authenticating as user2...${RESET_FORMAT}"
gcloud auth login --no-launch-browser --quiet

echo "${BLUE_TEXT}${BOLD_TEXT}Configuring user2 settings...${RESET_FORMAT}"
gcloud config set project $(gcloud config get-value project --configuration=default) --configuration=user2
gcloud config set compute/zone $(gcloud config get-value compute/zone --configuration=default) --configuration=user2
gcloud config set compute/region $(gcloud config get-value compute/region --configuration=default) --configuration=user2

echo "${BLUE_TEXT}${BOLD_TEXT}Switching to default configuration...${RESET_FORMAT}"
gcloud config configurations activate default

echo "${RED_TEXT}${BOLD_TEXT}Installing epel-release and jq packages...${RESET_FORMAT}"
sudo yum -y install epel-release
sudo yum -y install jq

echo
echo "${BLUE_TEXT}${BOLD_TEXT}Provide the following environment details:${RESET_FORMAT}"
echo

get_and_export_values() {
    read -p "${RED_TEXT}${BOLD_TEXT}Enter PROJECTID2: ${RESET_FORMAT}" PROJECTID2
    read -p "${RED_TEXT}${BOLD_TEXT}Enter USERID2: ${RESET_FORMAT}" USERID2
    read -p "${RED_TEXT}${BOLD_TEXT}Enter ZONE2: ${RESET_FORMAT}" ZONE2

    export PROJECTID2 USERID2 ZONE2
    echo "export PROJECTID2=$PROJECTID2" >> ~/.bashrc
    echo "export USERID2=$USERID2" >> ~/.bashrc
    echo "export ZONE2=$ZONE2" >> ~/.bashrc
    echo "${BLUE_TEXT}${BOLD_TEXT}Values saved to bashrc configuration${RESET_FORMAT}"
}

get_and_export_values

echo
echo "${RED_TEXT}${BOLD_TEXT}Granting Viewer role to ${USERID2}...${RESET_FORMAT}"
. ~/.bashrc
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/viewer

echo "${BLUE_TEXT}${BOLD_TEXT}Activating user2 configuration...${RESET_FORMAT}"
gcloud config configurations activate user2

echo "${BLUE_TEXT}${BOLD_TEXT}Setting project to ${PROJECTID2}...${RESET_FORMAT}"
gcloud config set project $PROJECTID2

echo "${RED_TEXT}${BOLD_TEXT}Returning to default configuration...${RESET_FORMAT}"
gcloud config configurations activate default

echo "${BLUE_TEXT}${BOLD_TEXT}Creating custom devops role...${RESET_FORMAT}"
gcloud iam roles create devops --project $PROJECTID2 \
--permissions "compute.instances.create,compute.instances.delete,compute.instances.start,compute.instances.stop,compute.instances.update,compute.disks.create,compute.subnetworks.use,compute.subnetworks.useExternalIp,compute.instances.setMetadata,compute.instances.setServiceAccount"

echo "${RED_TEXT}${BOLD_TEXT}Assigning devops roles to ${USERID2}...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=projects/$PROJECTID2/roles/devops

echo "${BLUE_TEXT}${BOLD_TEXT}Switching to user2 configuration...${RESET_FORMAT}"
gcloud config configurations activate user2

echo "${RED_TEXT}${BOLD_TEXT}Creating VM lab-2 in ${ZONE2}...${RESET_FORMAT}"
gcloud compute instances create lab-2 --zone $ZONE2 --machine-type=e2-standard-2

echo "${BLUE_TEXT}${BOLD_TEXT}Final switch back to default configuration...${RESET_FORMAT}"
gcloud config configurations activate default

echo "${BLUE_TEXT}${BOLD_TEXT}Updating project setting for ${PROJECTID2}...${RESET_FORMAT}"
gcloud config set project $PROJECTID2

echo "${RED_TEXT}${BOLD_TEXT}Creating devops service account...${RESET_FORMAT}"
gcloud iam service-accounts create devops --display-name devops

echo "${BLUE_TEXT}${BOLD_TEXT}Retrieving service account email...${RESET_FORMAT}"
SA=$(gcloud iam service-accounts list --format="value(email)" --filter "displayName=devops")
echo "${BLUE_TEXT}Service Account: ${SA}${RESET_FORMAT}"

echo "${RED_TEXT}${BOLD_TEXT}Granting permissions to service account...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/compute.instanceAdmin

echo "${RED_TEXT}${BOLD_TEXT}Deploying VM lab-3 with service account...${RESET_FORMAT}"
gcloud compute instances create lab-3 --zone $ZONE2 --machine-type=e2-standard-2 --service-account $SA --scopes "https://www.googleapis.com/auth/compute"


echo
echo "${RED_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}         ✅ LAB COMPLETED SUCCESSFULLY!                       ${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}🙏 Thanks for learning with SPARKWAVE DEV ✨${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}📢 Subscribe for more Google Cloud Labs:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwavedev${RESET_FORMAT}"
echo

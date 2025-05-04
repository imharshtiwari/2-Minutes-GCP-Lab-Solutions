#!/bin/bash

# Bright Foreground Colors
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Displaying start message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                  Starting the process...                   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

echo
read -p "${YELLOW_TEXT}${BOLD_TEXT} Enter ZONE: ${RESET_FORMAT}" ZONE
export ZONE=$ZONE
export REGION="${ZONE%-*}"

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Setting the compute zone and region ========================== ${RESET_FORMAT}"
echo

gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Creating a compute instance 'gcelab' ========================== ${RESET_FORMAT}"
echo

gcloud compute instances create gcelab --zone $ZONE --machine-type e2-standard-2

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Creating a disk 'mydisk' of 200GB ========================== ${RESET_FORMAT}"
echo

gcloud compute disks create mydisk --size=200GB \
--zone $ZONE

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Attaching disk 'mydisk' to instance 'gcelab' ========================== ${RESET_FORMAT}"
echo

gcloud compute instances attach-disk gcelab --disk mydisk --zone $ZONE

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Creating the 'prepare_disk.sh' script ========================== ${RESET_FORMAT}"
echo

cat > prepare_disk.sh <<'EOF_END'

ls -l /dev/disk/by-id/

sudo mkdir /mnt/mydisk

sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1

sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk

EOF_END

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Transfering script 'prepare_disk.sh' to 'gcelab' instance ========================== ${RESET_FORMAT}"
echo

gcloud compute scp prepare_disk.sh gcelab:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Executing the 'prepare_disk.sh' script on 'gcelab' ========================== ${RESET_FORMAT}"
echo

gcloud compute ssh gcelab --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe to SparkWave :${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@sparkwave.01${RESET_FORMAT}"
echo

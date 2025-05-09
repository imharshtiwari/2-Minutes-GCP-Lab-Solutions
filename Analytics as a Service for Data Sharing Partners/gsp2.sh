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


echo "${YELLOW_TEXT}${BOLD_TEXT}🛠️  Please provide your Main Lab Project ID.${RESET_FORMAT}"
read -p "${YELLOW_TEXT}${BOLD_TEXT}➡️  Main Lab Project ID: ${RESET_FORMAT}" MAIN_LAB_PROJECT_ID
export MAIN_LAB_PROJECT_ID

echo
echo "${GREEN_TEXT}✅ Main Lab Project ID has been set to: ${BOLD_TEXT}$MAIN_LAB_PROJECT_ID${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Creating a BigQuery view...${RESET_FORMAT}"
echo

bq mk --use_legacy_sql=false \
  --view "SELECT geos.zip_code, geos.city, cust.last_name, cust.first_name
FROM \`$DEVSHELL_PROJECT_ID.customer_b_dataset.customer_info\` as cust
JOIN \`$MAIN_LAB_PROJECT_ID.demo_dataset.authorized_view_b\` as geos
ON geos.zip_code = cust.postal_code;" \
  customer_b_dataset.customer_b_table

echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉 Success! The BigQuery view has been created.${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🎬  PLEASE PROCEED WITH THE VIDEO TUTORIAL 🎬${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🔗 ACCESS LOOKER STUDIO VIA THIS LINK: 🔗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://lookerstudio.google.com/ ${RESET_FORMAT}"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 IF YOU FOUND THIS HELPFUL, SUBSCRIBE SparkWave ! 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwave.01${RESET_FORMAT}"
echo

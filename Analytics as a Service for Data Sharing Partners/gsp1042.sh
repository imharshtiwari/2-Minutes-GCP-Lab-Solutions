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

echo "${YELLOW_TEXT}${BOLD_TEXT}✨ Creating an authorized view named 'authorized_view_a'. ✨${RESET_FORMAT}"
echo
bq mk \
--use_legacy_sql=false \
--description "DESCRIPTION" \
--view 'SELECT * FROM `bigquery-public-data.geo_us_boundaries.zip_codes`
WHERE state_code="TX"
LIMIT 4000' \
--project_id $DEVSHELL_PROJECT_ID \
demo_dataset.authorized_view_a

echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ View 'authorized_view_a' creation command initiated.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}✨ Now, proceeding to create another authorized view: 'authorized_view_b'. ✨${RESET_FORMAT}"
echo
bq mk \
--use_legacy_sql=false \
--description "DESCRIPTION" \
--view 'SELECT * FROM `bigquery-public-data.geo_us_boundaries.zip_codes`
WHERE state_code="CA"
LIMIT 4000' \
--project_id $DEVSHELL_PROJECT_ID \
demo_dataset.authorized_view_b

echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ View 'authorized_view_b' creation command initiated.${RESET_FORMAT}"
echo

echo
echo "${CYAN_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🎬  PLEASE PROCEED WITH THE VIDEO TUTORIAL 🎬${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo

echo "${WHITE_TEXT}${BOLD_TEXT}Your Project ID for the upcoming steps is: ${GREEN_TEXT}$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🔗 ACCESS BIGQUERY CONSOLE VIA THIS LINK: 🔗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://console.cloud.google.com/bigquery?project=$DEVSHELL_PROJECT_ID ${RESET_FORMAT}"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 IF YOU FOUND THIS HELPFUL, SUBSCRIBE SparkWave! 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwave.01${RESET_FORMAT}"
echo

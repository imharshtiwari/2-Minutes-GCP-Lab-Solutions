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
echo "${CYAN_TEXT}${BOLD_TEXT}=========================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🚀         INITIATING EXECUTION         🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=========================================${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}ℹ️  We will download the Vegeta load testing tool.${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🌐 This tool will be used for generating traffic.${RESET_FORMAT}"
curl -LO 'https://github.com/tsenart/vegeta/releases/download/v12.12.0/vegeta_12.12.0_linux_386.tar.gz'
echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Vegeta download complete.${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}ℹ️  Now, let's extract the downloaded Vegeta archive.${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}📦 This will make the Vegeta executable available.${RESET_FORMAT}"
tar -xvzf vegeta_12.12.0_linux_386.tar.gz
echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Vegeta extraction complete.${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}ℹ️  We are about to create a Cloud Logging metric.${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}📊 This metric will track latency for the 'helloWorld' Cloud Run function.${RESET_FORMAT}"
gcloud logging metrics create CloudFunctionLatency-Logs \
  --project=$DEVSHELL_PROJECT_ID \
  --description="awesome lab" \
  --log-filter='resource.type="cloud_run_revision" AND resource.labels.function_name="helloWorld"'
echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Cloud Logging metric creation command executed.${RESET_FORMAT}"
echo

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 Hope you found this video helpful! Consider subscribing to SparkWave 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@sparkwave.01${RESET_FORMAT}"
echo

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

export PROJECT_ID=$(gcloud info --format='value(config.project)')
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Project ID set to:${RESET_FORMAT} ${PROJECT_ID}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 1: Fetching all 'fullVisitorId' entries...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
fullVisitorId
FROM \`data-to-insights.ecommerce.rev_transactions\`
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 1 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 2: Retrieving 'fullVisitorId' and 'hits_page_pageTitle' (limit 1000)... 📄${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT fullVisitorId hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\` LIMIT 1000
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 2 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 3: Correctly fetching 'fullVisitorId' and 'hits_page_pageTitle' (limit 1000)... ✔️${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
  fullVisitorId
  , hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\` LIMIT 1000
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 3 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 4: Counting distinct visitors per page title... 📊${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\`
GROUP BY hits_page_pageTitle
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 4 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 5: Counting distinct visitors for 'Checkout Confirmation' page... 🛒${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM \`data-to-insights.ecommerce.rev_transactions\`
WHERE hits_page_pageTitle = 'Checkout Confirmation'
GROUP BY hits_page_pageTitle
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 5 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 6: Aggregating transactions and distinct visitors by city... 🏙️${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS totals_transactions,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 6 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 7: Same as Query 6, but ordered by distinct visitors (descending)... 📉${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS totals_transactions,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
ORDER BY distinct_visitors DESC
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 7 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 8: Calculating average products ordered per visitor by city... 📈${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS total_products_ordered,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
ORDER BY avg_products_ordered DESC
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 8 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 9: Filtering cities where average products ordered > 20... 🎯${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
geoNetwork_city,
SUM(totals_transactions) AS total_products_ordered,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
FROM
\`data-to-insights.ecommerce.rev_transactions\`
GROUP BY geoNetwork_city
HAVING avg_products_ordered > 20
ORDER BY avg_products_ordered DESC
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 9 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 10: Listing distinct product names and categories... 🛍️${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT hits_product_v2ProductName, hits_product_v2ProductCategory
FROM \`data-to-insights.ecommerce.rev_transactions\`
GROUP BY 1,2
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 10 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 11: Counting non-null products per category... 🔢${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(hits_product_v2ProductName) as number_of_products,
hits_product_v2ProductCategory
FROM \`data-to-insights.ecommerce.rev_transactions\`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 11 Completed.${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Executing Query 12: Counting distinct non-null products per category (Top 5)... 🏆${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
COUNT(DISTINCT hits_product_v2ProductName) as number_of_products,
hits_product_v2ProductCategory
FROM \`data-to-insights.ecommerce.rev_transactions\`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC
LIMIT 5
"
echo "${GREEN_TEXT}${BOLD_TEXT}✨ Query 12 Completed.${RESET_FORMAT}"
echo

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 Enjoyed the video? Consider subscribing to SparkWave 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@spakrwave.01${RESET_FORMAT}"
echo

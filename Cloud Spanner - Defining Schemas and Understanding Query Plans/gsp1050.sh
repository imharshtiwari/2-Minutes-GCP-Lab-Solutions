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

BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET=$(tput sgr0)

# Text Colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Background Colors
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)


clear
echo "${BG_BLUE}${BOLD}${WHITE}==================================================${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}   WELCOME TO SPARKWAVE DEV CLOUD TUTORIALS       ${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}==================================================${RESET}"
echo ""
echo "${CYAN}${BOLD}⚡ Expertly crafted by SPARKWAVE DEV${RESET}"
echo "${YELLOW}${BOLD}📺 YouTube: ${UNDERLINE}https://www.youtube.com/@sparkwavedev${RESET}"
echo ""

# ======================
#  DATABASE OPERATIONS
# ======================
echo "${MAGENTA}${BOLD}💼 STEP 1: Setting Up Portfolios...${RESET}"
declare -A PORTFOLIOS=(
    [1]="Banking,Bnkg,All Banking Business"
    [2]="Asset Growth,AsstGrwth,All Asset Focused Products"
    [3]="Insurance,Ins,All Insurance Focused Products"
)

for id in "${!PORTFOLIOS[@]}"; do
    IFS=',' read -r name short info <<< "${PORTFOLIOS[$id]}"
    echo "${WHITE}Creating portfolio: ${YELLOW}$name${RESET}"
    gcloud spanner databases execute-sql banking-ops-db \
        --instance=banking-ops-instance \
        --sql="INSERT INTO Portfolio (PortfolioId, Name, ShortName, PortfolioInfo) VALUES ($id, '$name', '$short', '$info')"
done
echo "${GREEN}${BOLD}✔ Portfolios created successfully${RESET}"
echo ""

# ======================
#  CATEGORY SETUP
# ======================
echo "${MAGENTA}${BOLD}🗂️ STEP 2: Creating Product Categories...${RESET}"
declare -A CATEGORIES=(
    [1]="1,Cash"
    [2]="2,Investments - Short Return"
    [3]="2,Annuities"
    [4]="3,Life Insurance"
)

for id in "${!CATEGORIES[@]}"; do
    IFS=',' read -r portfolio_id name <<< "${CATEGORIES[$id]}"
    echo "${WHITE}Creating category: ${YELLOW}$name${RESET}"
    gcloud spanner databases execute-sql banking-ops-db \
        --instance=banking-ops-instance \
        --sql="INSERT INTO Category (CategoryId, PortfolioId, CategoryName) VALUES ($id, $portfolio_id, '$name')"
done
echo "${GREEN}${BOLD}✔ Categories created successfully${RESET}"
echo ""

# ======================
#  PRODUCT SETUP
# ======================
echo "${MAGENTA}${BOLD}🛒 STEP 3: Adding Financial Products...${RESET}"
declare -A PRODUCTS=(
    [1]="1,1,Checking Account,ChkAcct,Banking LOB"
    [2]="2,2,Mutual Fund Consumer Goods,MFundCG,Investment LOB"
    [3]="3,2,Annuity Early Retirement,AnnuFixed,Investment LOB"
    [4]="4,3,Term Life Insurance,TermLife,Insurance LOB"
    [5]="1,1,Savings Account,SavAcct,Banking LOB"
    [6]="1,1,Personal Loan,PersLn,Banking LOB"
    [7]="1,1,Auto Loan,AutLn,Banking LOB"
    [8]="4,3,Permanent Life Insurance,PermLife,Insurance LOB"
    [9]="2,2,US Savings Bonds,USSavBond,Investment LOB"
)

for id in "${!PRODUCTS[@]}"; do
    IFS=',' read -r category_id portfolio_id name code class <<< "${PRODUCTS[$id]}"
    echo "${WHITE}Adding product: ${YELLOW}$name${RESET}"
    gcloud spanner databases execute-sql banking-ops-db \
        --instance=banking-ops-instance \
        --sql="INSERT INTO Product (ProductId, CategoryId, PortfolioId, ProductName, ProductAssetCode, ProductClass) VALUES ($id, $category_id, $portfolio_id, '$name', '$code', '$class')"
done
echo "${GREEN}${BOLD}✔ Financial products added successfully${RESET}"
echo ""

# ======================
#  PYTHON HELPER SCRIPTS
# ======================
echo "${MAGENTA}${BOLD}🐍 STEP 4: Running Python Helper Scripts...${RESET}"
echo "${WHITE}Setting up Python environment...${RESET}"
mkdir -p python-helper && cd python-helper || {
    echo "${RED}${BOLD}❌ Failed to create python-helper directory${RESET}"
    exit 1
}

wget -q https://storage.googleapis.com/cloud-training/OCBL373/requirements.txt
wget -q https://storage.googleapis.com/cloud-training/OCBL373/snippets.py

pip install -q -r requirements.txt
pip install -q setuptools

echo "${WHITE}Executing database operations...${RESET}"
declare -a PYTHON_COMMANDS=(
    "insert_data"
    "query_data"
    "add_column"
    "update_data"
    "query_data_with_new_column"
    "add_index"
)

for command in "${PYTHON_COMMANDS[@]}"; do
    echo "${WHITE}Running: ${YELLOW}$command${RESET}"
    python snippets.py banking-ops-instance --database-id banking-ops-db $command
done
echo "${GREEN}${BOLD}✔ Python operations completed successfully${RESET}"
echo ""

# ======================
#  COMPLETION MESSAGE
# ======================
echo "${BG_GREEN}${BLACK}${BOLD}==================================================${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}   LAB COMPLETE!   ${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}==================================================${RESET}"
echo ""
echo "${WHITE}${BOLD}🔍 Access your Cloud Spanner database at:${RESET}"
echo "${BLUE}https://console.cloud.google.com/spanner/instances/banking-ops-instance/databases/banking-ops-db${RESET}"
echo ""
echo "${CYAN}${BOLD}💡 For more Google Cloud labs and tutorials:${RESET}"
echo "${YELLOW}${BOLD}👉 ${UNDERLINE}https://www.youtube.com/@sparkwavedev${RESET}"
echo "${GREEN}${BOLD}🔔 Don't forget to subscribe for daily cloud tutorials!${RESET}"

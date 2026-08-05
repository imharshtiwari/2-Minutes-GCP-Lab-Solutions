# Establish VPC to VPC Connectivity using NCC || [GSP1317](https://www.skills.google/catalog_lab/32126) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwavedev)

> [!IMPORTANT] 
> This is an independent, community-made walkthrough created to help you understand why each step works. Attempt the challenge yourself first. This guide is provided for educational purposes and is not intended to replace the official lab instructions or your own hands-on learning. It is not affiliated with or endorsed by Google Cloud or Google Cloud Skills Boost. Always follow the official Google Cloud and Qwiklabs terms of service, lab instructions, and usage policies.

> This lab focuses on advanced Google Cloud networking concepts, including Network Connectivity Center (NCC), VPC connectivity, Private Service Connect (PSC), Cloud SQL, and resource lifecycle management. The lab is fully automated, but the order of execution is critical because the automated grader depends on the provisioned resources being available when you check your progress. Do not delete or clean up resources until the lab tracker shows the required 100/100 score. Always follow the official lab instructions and use the exact values and resources provided by your current lab session.

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
echo -e "${BLUE}${BOLD}║   🚀 TARGET: GSP1317 FULL MESH VPC CONNECTIVITY WITH NCC   ║${RESET}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}\n"

# ==============================================================================
# PRE-FLIGHT CHECKS & VARIABLES
# ==============================================================================
echo -e "${BOLD}${YELLOW}[SPARKWAVE  DEV ✨] Auto-fetching Project, Zone, and Region...${RESET}"
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

export ZONE=$(gcloud compute instances list --filter="name=cloudsql-client" --format="value(zone)" 2>/dev/null | head -n 1)
if [[ -z "$ZONE" ]]; then
    read -p "$(echo -e ${BOLD}${CYAN}"Could not detect zone. Please enter the lab Zone (e.g., us-east1-b): "${RESET})" ZONE
    export ZONE
fi
export REGION=${ZONE%-*}

echo -e "✅ Project ID: ${GREEN}$PROJECT_ID${RESET}"
echo -e "✅ Zone:       ${GREEN}$ZONE${RESET}"
echo -e "✅ Region:     ${GREEN}$REGION${RESET}\n"

# ==============================================================================
# TASK 1 & 2: NCC HUB & SPOKES
# ==============================================================================
echo -e "${GREEN}${BOLD}▬▬▬▬▬▬ TASK 1 & 2: CONFIGURE NCC HUB AND SPOKES ▬▬▬▬▬▬${RESET}"
echo -e "${YELLOW}[*] Enabling Network Connectivity API...${RESET}"
gcloud services enable networkconnectivity.googleapis.com --quiet

echo -e "${YELLOW}[*] Creating NCC Hub (ncc-hub)...${RESET}"
gcloud network-connectivity hubs create ncc-hub --quiet

echo -e "${YELLOW}[*] Configuring VPC1 as an NCC Spoke...${RESET}"
gcloud network-connectivity spokes linked-vpc-network create vpc1-spoke1 \
  --hub=ncc-hub \
  --vpc-network=vpc1-ncc \
  --exclude-export-ranges=10.1.2.0/24 \
  --global --quiet

echo -e "${YELLOW}[*] Configuring VPC2 as an NCC Spoke...${RESET}"
gcloud network-connectivity spokes linked-vpc-network create vpc2-spoke2 \
  --hub=ncc-hub \
  --vpc-network=vpc2-ncc \
  --exclude-export-ranges=10.3.3.0/24 \
  --global --quiet

# ==============================================================================
# TASK 4: PRIVATE SERVICE CONNECT (PSC)
# ==============================================================================
echo -e "\n${GREEN}${BOLD}▬▬▬▬▬▬ TASK 4: SET UP PRIVATE SERVICE CONNECT ▬▬▬▬▬▬${RESET}"
echo -e "${YELLOW}[*] Deriving a safe IP address from VPC2 subnet...${RESET}"
CIDR=$(gcloud compute networks subnets describe vpc2-ncc-subnet1 --region=$REGION --format="value(ipCidrRange)")
ADDRESS=$(python3 -c "import ipaddress; net=ipaddress.IPv4Network('$CIDR'); print(str(net[99]))")
echo -e "✅ Reserved IP: ${CYAN}$ADDRESS${RESET}"

gcloud compute addresses create cloudsql-psc \
  --region=$REGION \
  --subnet=vpc2-ncc-subnet1 \
  --addresses=$ADDRESS \
  --quiet

echo -e "${YELLOW}[*] Fetching Cloud SQL Service Attachment URI...${RESET}"
SQL_INSTANCE=$(gcloud sql instances list --format="value(name)" | head -n 1)
ATTACH_URI=$(gcloud sql instances describe $SQL_INSTANCE --format="value(pscServiceAttachmentLink)")

echo -e "${YELLOW}[*] Creating Private Service Connect Endpoint...${RESET}"
gcloud compute forwarding-rules create cloudsql-psc-ep \
  --address=cloudsql-psc \
  --region=$REGION \
  --network=vpc2-ncc  \
  --target-service-attachment=$ATTACH_URI \
  --allow-psc-global-access \
  --quiet

echo -e "${YELLOW}[*] Configuring Private DNS Managed Zone...${RESET}"
gcloud dns managed-zones create cloudsql-dns \
  --description="DNS zone for the Cloud SQL instances" \
  --dns-name=$REGION.sql.goog. \
  --networks=vpc2-ncc  \
  --visibility=private \
  --quiet

DNS_RECORD=$(gcloud sql instances describe $SQL_INSTANCE --format="value(dnsName)")
echo -e "${YELLOW}[*] Adding DNS Record: ${CYAN}$DNS_RECORD${RESET}"
gcloud dns record-sets create $DNS_RECORD \
  --type=A \
  --rrdatas=$ADDRESS \
  --zone=cloudsql-dns \
  --quiet

# ==============================================================================
# TASK 5: CONNECT TO CLOUD SQL VIA PSC
# ==============================================================================
echo -e "\n${GREEN}${BOLD}▬▬▬▬▬▬ TASK 5: AUTOMATING CLOUD SQL CONFIGURATIONS ▬▬▬▬▬▬${RESET}"
echo -e "${YELLOW}[*] Generating remote SQL script...${RESET}"
cat << 'EOF' > run_sql.sh
#!/bin/bash
export PGPASSWORD="changeme"
psql "sslmode=disable dbname=postgres user=postgres host=$1" -c "CREATE DATABASE company;"
psql "sslmode=disable dbname=company user=postgres host=$1" -c "
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first VARCHAR(255) NOT NULL,
    last VARCHAR(255) NOT NULL,
    salary DECIMAL (10, 2)
);
INSERT INTO employees (first, last, salary) VALUES
    ('Max', 'Mustermann', 5000.00),
    ('Anna', 'Schmidt', 7000.00),
    ('Peter', 'Mayer', 6000.00);
"
EOF

echo -e "${YELLOW}[*] Executing script remotely on cloudsql-client via SSH...${RESET}"
gcloud compute scp run_sql.sh cloudsql-client:~ --zone=$ZONE --tunnel-through-iap --quiet
gcloud compute ssh cloudsql-client --zone=$ZONE --tunnel-through-iap --command="bash run_sql.sh $DNS_RECORD" --quiet

echo -e "\n${MAGENTA}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAGENTA}${BOLD}║           🎉 LAB COMPLETED SUCCESSFULLY 🎉                  ║${RESET}"
echo -e "${MAGENTA}${BOLD}╚========== ✨✨ SUBSCRIBE TO SPARKWAVE DEV ✨✨=============${RESET}"
echo -e "${MAGENTA}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo -e "${CYAN}${BOLD}⚠️ CRITICAL: Check your progress in Qwiklabs NOW and wait until you have 100/100 points BEFORE running Part 2! ⚠️${RESET}\n"

```

### 🐼 Congratulations 🎉 for completing the Challenge Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# ✨✨[SPARKWAVE DEV](https://www.youtube.com/@sparkwavedev) ✨✨

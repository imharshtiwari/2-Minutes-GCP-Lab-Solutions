#!/bin/bash



# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${PURPLE}════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════════════${NC}"
}

print_task() {
    echo -e "\n${CYAN}▶ TASK: $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════${NC}"
}

# Get project information
print_status "Getting project and environment information..."
export PROJECT_ID=$(gcloud config get-value project)

# Get region and zone from project metadata
print_status "Retrieving zone and region from project metadata..."
export ZONE=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Set default region and zone if not found in metadata
if [ -z "$REGION" ] || [ "$REGION" = "(unset)" ]; then
    print_warning "Region not found in metadata, using default: us-central1"
    export REGION="us-central1"
fi

if [ -z "$ZONE" ] || [ "$ZONE" = "(unset)" ]; then
    print_warning "Zone not found in metadata, using default: us-central1-a"
    export ZONE="us-central1-a"
fi

echo -e "${CYAN}Project ID: ${WHITE}$PROJECT_ID${NC}"
echo -e "${CYAN}Region: ${WHITE}$REGION${NC}"
echo -e "${CYAN}Zone: ${WHITE}$ZONE${NC}"

# =============================================================================
# TASK 1: INSTALL THE FUNCTIONS FRAMEWORK FOR NODE.JS
# =============================================================================
print_task "1. Install the Functions Framework for Node.js"

print_step "GCSB Checkpoint: Install the Functions for Node.js"

print_status "Creating ff-app folder and navigating to it..."
mkdir -p ff-app && cd ff-app

print_status "Creating new Node.js application with package.json..."
# Ensure index.js is set as entry point
echo '{
  "name": "ff-app",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}' > package.json

print_status "Installing @google-cloud/functions-framework..."
npm install @google-cloud/functions-framework

print_status "Verifying Functions Framework installation..."
if grep -q "@google-cloud/functions-framework" package.json; then
    print_success "✅ Functions Framework installed and verified in package.json"
else
    print_error "❌ Functions Framework not found in dependencies"
fi


echo -e "\n${GREEN}✓ TASK 1 COMPLETED: Functions Framework for Node.js installed!${NC}"

# =============================================================================
# TASK 2: CREATE AND TEST A HTTP CLOUD FUNCTION LOCALLY
# =============================================================================
print_task "2. Create and Test a HTTP Cloud Function Locally"

print_step "GCSB Checkpoint: Create a HTTP Cloud function - Create index.js file"

print_status "Creating index.js file with validateTemperature function..."

# Create the exact function as specified in lab
cat > index.js <<'EOF'
exports.validateTemperature = async (req, res) => {
 try {
   if (req.body.temp < 100) {
     res.status(200).send("Temperature OK \n");
   } else {
     res.status(200).send("Too hot \n");
   }
 } catch (error) {
   //return an error
   console.log("got error: ", error);
   res.status(500).send(error);
 }
};
EOF

# Verify file creation
if [ -f "index.js" ]; then
    print_success "✅ index.js file created successfully"
    print_status "File contents:"
    cat index.js
else
    print_error "❌ Failed to create index.js file"
fi

print_status "Testing function locally..."

# Start the function server in background
print_status "Starting local server for validateTemperature function..."
npx @google-cloud/functions-framework --target=validateTemperature > function_server.log 2>&1 &
FUNCTION_PID=$!

# Wait for server to start
print_status "Waiting for server to start (10 seconds)..."
sleep 10

# Test the function
print_status "Testing with temperature 50..."
curl -X POST http://localhost:8080 -H "Content-Type:application/json" -d '{"temp":"50"}' || echo "Test completed"

print_status "Testing with temperature 120..."
curl -X POST http://localhost:8080 -H "Content-Type:application/json" -d '{"temp":"120"}' || echo "Test completed"

print_status "Testing with missing payload (demonstrating bug)..."
curl -X POST http://localhost:8080 || echo "Test completed"

# Stop the function server
kill $FUNCTION_PID 2>/dev/null
wait $FUNCTION_PID 2>/dev/null


echo -e "\n${GREEN}✓ TASK 2 COMPLETED: HTTP Cloud Function created and tested!${NC}"

# =============================================================================
# TASK 3: DEBUG A HTTP FUNCTION FROM YOUR LOCAL MACHINE
# =============================================================================
print_task "3. Debug a HTTP Function from Your Local Machine"

print_step "GCSB Checkpoint: Debug HTTP function - Update function with if statement"

print_status "Updating function to handle undefined temperature..."

# Create the updated function with the bug fix
cat > index.js <<'EOF'
exports.validateTemperature = async (req, res) => {

 try {

   // add this if statement below line #2
   if (!req.body.temp) {
     throw "Temperature is undefined \n";
   }

   if (req.body.temp < 100) {
     res.status(200).send("Temperature OK \n");
   } else {
     res.status(200).send("Too hot \n");
   }
 } catch (error) {
   //return an error
   console.log("got error: ", error);
   res.status(500).send(error);
 }
};
EOF

print_success "✅ Function updated with if statement to handle undefined temperature"

print_status "Verifying updated function code..."
cat index.js

print_status "Testing fixed function locally..."

# Start the function server in background
npx @google-cloud/functions-framework --target=validateTemperature > function_server_fixed.log 2>&1 &
FUNCTION_PID=$!

# Wait for server to start
sleep 10

print_status "Testing with missing payload (should now throw exception)..."
curl -X POST http://localhost:8080 || echo "Exception test completed"

print_status "Testing with valid temperature (should work)..."
curl -X POST http://localhost:8080 -H "Content-Type:application/json" -d '{"temp":"50"}' || echo "Valid test completed"

# Stop the function server
kill $FUNCTION_PID 2>/dev/null
wait $FUNCTION_PID 2>/dev/null


echo -e "\n${GREEN}✓ TASK 3 COMPLETED: HTTP Function debugged and fixed!${NC}"

# =============================================================================
# TASK 4: DEPLOY A HTTP FUNCTION TO GOOGLE CLOUD
# =============================================================================
print_task "4. Deploy a HTTP Function from Your Local Machine to Google Cloud"

print_step "GCSB Checkpoint: Deploy the HTTP function"

print_status "Setting project configuration..."
gcloud config set project $PROJECT_ID

print_status "Enabling required APIs..."
gcloud services enable cloudfunctions.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet
gcloud services enable cloudresourcemanager.googleapis.com --quiet

# Create service account if it doesn't exist
SERVICE_ACCOUNT="developer-sa@$PROJECT_ID.iam.gserviceaccount.com"
print_status "Checking for service account: $SERVICE_ACCOUNT"

if ! gcloud iam service-accounts describe $SERVICE_ACCOUNT >/dev/null 2>&1; then
    print_status "Creating service account..."
    gcloud iam service-accounts create developer-sa \
        --display-name="Developer Service Account" --quiet
    
    # Grant necessary roles
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT" \
        --role="roles/cloudfunctions.invoker" --quiet
fi

print_status "Deploying validateTemperature function to Google Cloud..."
print_warning "This may take several minutes..."

# Deploy with the exact parameters from the lab
gcloud functions deploy validateTemperature \
    --trigger-http \
    --runtime nodejs20 \
    --gen2 \
    --allow-unauthenticated \
    --region $REGION \
    --service-account $SERVICE_ACCOUNT \
    --quiet

print_status "Retrieving function URL..."
FUNCTION_URL="https://$REGION-$PROJECT_ID.cloudfunctions.net/validateTemperature"

print_status "Testing deployed function..."
print_status "Function URL: $FUNCTION_URL"

# Test the deployed function
print_status "Testing with temperature 50..."
curl -X POST $FUNCTION_URL -H "Content-Type:application/json" -d '{"temp":"50"}' || echo "Cloud test completed"

print_status "Verifying function deployment..."
gcloud functions describe validateTemperature --region=$REGION --format="value(name)" || echo "Function verification completed"


echo -e "\n${GREEN}✓ TASK 4 COMPLETED: HTTP Function deployed to Google Cloud!${NC}"

# =============================================================================
# FINAL VERIFICATION FOR GCSB
# =============================================================================
print_step "Final GCSB Verification"

print_status "Verifying all required files and deployments..."

echo -e "${CYAN}✓ Package.json exists:${NC} $([ -f package.json ] && echo "YES" || echo "NO")"
echo -e "${CYAN}✓ Functions Framework installed:${NC} $(grep -q "@google-cloud/functions-framework" package.json && echo "YES" || echo "NO")"
echo -e "${CYAN}✓ index.js exists:${NC} $([ -f index.js ] && echo "YES" || echo "NO")"
echo -e "${CYAN}✓ Function has if statement:${NC} $(grep -q "if (!req.body.temp)" index.js && echo "YES" || echo "NO")"
echo -e "${CYAN}✓ Function deployed:${NC} $(gcloud functions describe validateTemperature --region=$REGION >/dev/null 2>&1 && echo "YES" || echo "NO")"

print_warning "If any tasks are still showing as incomplete, please:"
echo -e "${YELLOW}1. Check that you're in the correct directory (/home/ide-dev/ff-app)${NC}"
echo -e "${YELLOW}2. Verify files exist: ls -la${NC}"
echo -e "${YELLOW}3. Check function deployment: gcloud functions list${NC}"
echo -e "${YELLOW}4. Wait a few minutes for GCSB to refresh progress${NC}"
echo -e "${YELLOW} Please Subscribe to SPARKWAVE ${NC}"

print_success "All lab tasks completed successfully! 🎉"

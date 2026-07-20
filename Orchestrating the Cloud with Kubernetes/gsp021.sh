#!/bin/bash

# ==============================================
# Google Kubernetes Engine Complete Lab Setup
# Welcome to SPARKWAVE ✨ Cloud Tutorials!
# YouTube: https://www.youtube.com/@drSPARKWAVE.01/videos
# ==============================================

# ASCII Art Banner
echo "                                                                               
  ____  _       _     _           _    _           _       _     _   
 |  _ \(_)     | |   | |         | |  | |         | |     | |   | |  
 | |_) |_  __ _| |__ | |__   ___ | | _| | ___  ___| |_ ___| |__ | |_ 
 |  _ <| |/ _\` | '_ \| '_ \ / _ \| |/ / |/ _ \/ __| __/ __| '_ \| __|
 | |_) | | (_| | | | | | | | (_) |   <| |  __/\__ \ || (__| | | | |_ 
 |____/|_|\__, |_| |_|_| |_|\___/|_|\_\_|\___||___/\__\___|_| |_|\__|
           __/ |                                                     
          |___/                                                      
"

echo "=================================================================="
echo "           WELCOME TO SPARKWAVE CLOUD TUTORIALS!"
echo "=================================================================="
echo " YouTube Channel: https://www.youtube.com/@sparkwave.01/videos"
echo "=================================================================="
echo "    SUBSCRIBE for more Kubernetes and Cloud Computing tutorials!"
echo "=================================================================="
echo ""
sleep 3

echo "Starting Google Kubernetes Engine lab setup..."
echo "Subscribe bhi kro do for more videos and update"
echo "Working..."
echo ""

# Display progress function
progress() {
    echo "✅ $1"
    sleep 2
}

# Task: Initial Setup
progress "Setting up initial configuration..."
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

# Task: Create Kubernetes Cluster
progress "Creating Kubernetes cluster 'io' in zone: $ZONE"
gcloud container clusters create io --zone $ZONE

# Task: Get Sample Code
progress "Downloading sample code from Google Cloud Storage..."
gsutil cp -r gs://spls/gsp021/* .
cd orchestrate-with-kubernetes/kubernetes
ls

# Task: Quick Kubernetes Demo
progress "Creating nginx deployment (version 1.27.0)..."
kubectl create deployment nginx --image=nginx:1.27.0
kubectl get pods

progress "Exposing nginx as LoadBalancer service..."
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl get services

# Wait for external IP to be assigned
progress "Waiting for external IP assignment..."
sleep 30
kubectl get services

# Task: Create Fortune App Pod
progress "Creating fortune-app pod..."
kubectl create -f pods/fortune-app.yaml
kubectl get pods

progress "Describing fortune-app pod..."
kubectl describe pods fortune-app

# Task: Interact with Pods (Port Forwarding)
progress "Setting up port forwarding for fortune-app..."
echo "Note: Port forwarding runs in background for testing"
kubectl port-forward fortune-app 10080:8080 &
PORT_FORWARD_PID=$!
sleep 5

progress "Testing fortune app endpoint..."
curl http://127.0.0.1:10080

progress "Testing secure endpoint (expected to fail)..."
curl http://127.0.0.1:10080/secure

progress "Logging in to get authentication token..."
TOKEN=$(curl -s -u user:password http://127.0.0.1:10080/login | jq -r '.token')
echo "Token acquired successfully!"

progress "Testing secure endpoint with authentication token..."
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:10080/secure

progress "Viewing application logs..."
kubectl logs fortune-app

# Task: Create Secure Fortune Pod and Service
progress "Creating TLS certificates secret..."
kubectl create secret generic tls-certs --from-file tls/

progress "Creating nginx proxy configuration..."
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf

progress "Creating secure-fortune pod..."
kubectl create -f pods/secure-fortune.yaml

progress "Creating fortune-app service..."
kubectl create -f services/fortune-app.yaml

progress "Creating firewall rule for port 31000..."
gcloud compute firewall-rules create allow-fortune-nodeport --allow=tcp:31000

# Task: Add Labels to Pods
progress "Adding 'secure=enabled' label to secure-fortune pod..."
kubectl label pods secure-fortune 'secure=enabled'
kubectl get pods secure-fortune --show-labels

progress "Checking service endpoints..."
kubectl describe services fortune-app | grep Endpoints

# Test secure fortune service
progress "Testing secure fortune service externally..."
EXTERNAL_IP=$(gcloud compute instances list --format="value(EXTERNAL_IP)" | head -1)
curl -k https://$EXTERNAL_IP:31000

# Task: Create Microservices Deployments
progress "Creating auth microservice deployment..."
kubectl create -f deployments/auth.yaml

progress "Creating auth service..."
kubectl create -f services/auth.yaml

progress "Creating fortune service deployment..."
kubectl create -f deployments/hello.yaml

progress "Creating fortune service..."
kubectl create -f services/hello.yaml
kubectl create -f deployments/fortune-service.yaml
kubectl create -f services/fortune-service.yaml
progress "Creating frontend configuration..."
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf

progress "Creating frontend deployment..."
kubectl create -f deployments/frontend.yaml

progress "Creating frontend service..."
kubectl create -f services/frontend.yaml

# Wait for frontend service to get external IP
progress "Waiting for frontend external IP assignment..."
sleep 30

progress "Checking frontend service status..."
kubectl get services frontend

# Test frontend service
FRONTEND_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ ! -z "$FRONTEND_IP" ]; then
    progress "Testing frontend service at https://$FRONTEND_IP"
    curl -k https://$FRONTEND_IP
fi

# Task: Create Monolith (from original script)
progress "Creating monolith application..."
kubectl create -f pods/monolith.yaml
kubectl get pods

# Clean up port forwarding
kill $PORT_FORWARD_PID 2>/dev/null

# Final output
echo ""
echo "=================================================================="
echo "🎉 LAB SETUP COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo "All Kubernetes lab tasks have been executed successfully!"
echo ""
echo "📊 CURRENT STATUS:"
echo "=================================================================="
kubectl get pods
echo "------------------------------------------------------------------"
kubectl get services
echo "------------------------------------------------------------------"
kubectl get deployments
echo "=================================================================="

echo ""
echo "💡 NEXT STEPS:"
echo "1. Visit your frontend at: https://$FRONTEND_IP"
echo "2. Test your services using the endpoints above"
echo "3. Explore Kubernetes dashboard: kubectl proxy"
echo ""

echo "=============================================================================="
echo "📺 LIKE THIS TUTORIAL? SUBSCRIBE TO SPARKWAVE CLOUD TUTORIALS!"
echo "YouTube: https://www.youtube.com/@sparkwave.01/videos"
echo "=============================================================================="
echo "   Don't forget to like, share, and comment on the Kubernetes tutorials!"
echo "=============================================================================="

# Cluster info
echo ""
echo "🔧 Cluster Information:"
gcloud container clusters describe io --zone $ZONE --format="value(name, currentMasterVersion, endpoint)"

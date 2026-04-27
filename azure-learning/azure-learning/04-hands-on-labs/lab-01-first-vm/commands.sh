#!/usr/bin/env bash
# Lab 01 — First VM
# Run these commands one section at a time. Don't just run the whole file.

set -euo pipefail

# ==== Variables ====
RG="lab-01-rg"
LOCATION="centralindia"          # change to your nearest region
VM_NAME="lab-vm-01"
VM_SIZE="Standard_B1s"           # free-tier eligible
ADMIN_USER="azureuser"
IMAGE="Ubuntu2204"

# ==== 1. Login ====
az login
az account show --output table   # verify active subscription

# ==== 2. Create resource group ====
az group create \
  --name "$RG" \
  --location "$LOCATION"

# ==== 3. Create VM (auto-creates VNet, subnet, NSG, Public IP) ====
az vm create \
  --resource-group "$RG" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --public-ip-sku Standard

# Capture the public IP
PUBLIC_IP=$(az vm show \
  --resource-group "$RG" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)
echo "Public IP: $PUBLIC_IP"

# ==== 4. Open port 80 for HTTP ====
az vm open-port \
  --resource-group "$RG" \
  --name "$VM_NAME" \
  --port 80 \
  --priority 1001

# ==== 5. SSH in and install nginx ====
ssh "$ADMIN_USER@$PUBLIC_IP" << 'ENDSSH'
sudo apt update
sudo apt install -y nginx
sudo systemctl status nginx --no-pager
ENDSSH

# ==== 6. Verify ====
echo "Open in browser: http://$PUBLIC_IP"
curl -sI "http://$PUBLIC_IP" | head -1   # should return HTTP/1.1 200 OK

# ==== 7. CLEAN UP — don't skip this! ====
az group delete --name "$RG" --yes --no-wait
echo "Cleanup started. Verify with: az group exists --name $RG"

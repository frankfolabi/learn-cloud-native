#!/bin/bash

# This script is in two parts. 
# Part 1 for Docker setup
LOG_FILE="var/log/docker-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -e

# Update  the instance and install neccessary packages
echo "[INFO] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[INFO] Installing Git and Python..."
sudo apt install -y git python3 python3-pip curl

# Install and configure Docker
echo "[INFO] Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sleep 10
sudo reboot

#!/bin/bash

# This is part two to setup Kubernetes 
LOG_FILE="/var/log/k8s-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -e
echo "[INFO] Installing Kind..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
else
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
fi

echo "[INFO] Installing kubectl..."
VERSION="v1.30.0"
URL="https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
INSTALL_DIR="/usr/local/bin"

curl -LO "$URL"
chmod +x kubectl
sudo mv kubectl $INSTALL_DIR/

echo "[INFO] Waiting for Docker to be ready..."
until docker info >/dev/null 2>&1; do sleep 5; done

echo "[INFO] Creating Kind cluster config..."
CLUSTER_DIR="./kind-cluster"
sudo mkdir -p "$CLUSTER_DIR"
cd "$CLUSTER_DIR"

sudo tee kind-cluster-config.yaml > /dev/null <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.31.2
- role: worker
  image: kindest/node:v1.31.2
- role: worker
  image: kindest/node:v1.31.2
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

echo "[INFO] Creating Kind cluster..."
kind create cluster --name tws-cluster --config=kind-cluster-config.yaml

echo "[INFO] Exporting kubeconfig..."
kind export kubeconfig --name tws-cluster

echo "[INFO] Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

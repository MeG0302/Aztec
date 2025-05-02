#!/bin/bash

set -e

# === Update and install dependencies ===
echo "Updating and installing base packages..."
sudo apt-get update && sudo apt-get upgrade -y

sudo apt install -y \
  curl iptables build-essential git wget lz4 jq make gcc nano \
  automake autoconf tmux htop nvme-cli libgbm1 pkg-config \
  libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

# === Remove old container tools ===
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
  sudo apt-get remove -y $pkg || true
done

# === Install Docker ===
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y \
  linux-image-extra-$(uname -r) \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# === Add missing kernel modules ===
cat <<EOF | sudo tee /etc/modules-load.d/docker.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/99-docker.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl settings
sudo sysctl --system

# Load the modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Reconfigure systemd and restart Docker
sudo systemctl daemon-reexec
sudo systemctl enable docker
sudo systemctl restart docker || {
  echo "Docker failed to start. Check logs with: journalctl -xeu docker.service"
  exit 1
}

# === Test Docker ===
echo "Testing Docker..."
sudo docker run hello-world || true

# === Install Aztec Node ===
echo "Installing Aztec node..."
bash -i <(curl -s https://install.aztec.network)

# === Prompt for User Input ===
echo "Please enter your Layer 1 RPC URL:"
read -r RPC_URL

echo "Please enter your L1 consensus beacon URL:"
read -r BEACON_URL

echo "Enter your Sequencer Validator Private Key (starting with 0x):"
read -r SEQUENCER_KEY

echo "Enter your Sequencer Coinbase Address (starting with 0x):"
read -r COINBASE_ADDR

echo "Enter your Public IP address for P2P traffic:"
read -r P2P_IP

# === Firewall setup ===
echo "Configuring UFW firewall..."
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

# === Start Aztec node in screen ===
echo "Starting Aztec node in a screen session..."
screen -dmS aztec \
  aztec start --node --archiver --sequencer \
    --network alpha-testnet \
    --l1-rpc-urls "$RPC_URL" \
    --l1-consensus-host-urls "$BEACON_URL" \
    --sequencer.validatorPrivateKey "$SEQUENCER_KEY" \
    --sequencer.coinbase "$COINBASE_ADDR" \
    --p2p.p2pIp "$P2P_IP"

echo "Aztec node setup complete and running in screen session named 'aztec'."

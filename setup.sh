#!/bin/bash

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# === RetardMeG Design Banner ===
echo -e "\n${PURPLE}${BOLD}############################################${RESET}"
echo -e "${PURPLE}${BOLD}#                                          #${RESET}"
echo -e "${PURPLE}${BOLD}#          A Z T E C   N O D E             #${RESET}"
echo -e "${PURPLE}${BOLD}#             by RetardMeG                 #${RESET}"
echo -e "${PURPLE}${BOLD}#                                          #${RESET}"
echo -e "${PURPLE}${BOLD}############################################${RESET}\n"
echo -e "${LIGHTBLUE}${BOLD}📡 Twitter:  https://x.com/Jaishiva0302${RESET}"
echo -e "${LIGHTBLUE}${BOLD}💬 Telegram: https://t.me/vampsairdrop${RESET}\n"


EOF

sleep 7

# Run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root using: sudo su"
  exit 1
fi

# Go to home directory
cd

# System update and upgrade
echo "📦 Updating system..."
apt-get update && apt-get upgrade -y

# Install dependencies
echo "📚 Installing dependencies..."
apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# Install Docker
echo "🐳 Installing Docker..."
apt install docker.io -y

# Install Aztec CLI
echo "🚀 Installing Aztec CLI..."
bash -i <(curl -s https://install.aztec.network)

# Update PATH
echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Initialize Aztec CLI
aztec
aztec-up alpha-testnet

# Get public IP
public_ip=$(curl -s ipinfo.io/ip)
echo "🌐 Detected public IP: $public_ip"
echo "⚠️  Please save this IP before proceeding."
read -p "Have you saved it? (y/n): " saved
if [ "$saved" != "y" ]; then
  echo "❗ Save the IP and rerun the script."
  exit 1
fi

# Setup firewall
echo "🧱 Configuring firewall..."
ufw allow ssh
ufw allow 40400
ufw allow 40500
ufw allow 8080
ufw --force enable

# Prompt for wallet
read -p "🔐 Enter your EVM wallet address: " COINBASE

# Export environment variables
export DATA_DIRECTORY=/root/aztec-data/
export COINBASE=$COINBASE
export LOG_LEVEL=debug
export P2P_MAX_TX_POOL_SIZE=1000000000

# Prompt for RPC and validator info
read -p "🌍 Enter your Ethereum Sepolia RPC URL: " RPC_URL
read -p "🛰️  Enter your Ethereum Beacon Consensus RPC URL: " CONSENSUS_URL
read -p "📡 Enter your saved public IP address: " LOCAL_IP
read -p "🔑 Enter your validator private key: " PRIVATE_KEY

# Start the Aztec node
echo "🚦 Starting Aztec node..."
aztec start \
  --network alpha-testnet \
  --l1-rpc-urls "$RPC_URL" \
  --l1-consensus-host-urls "$CONSENSUS_URL" \
  --sequencer.validatorPrivateKey "$PRIVATE_KEY" \
  --p2p.p2pIp "$LOCAL_IP" \
  --p2p.maxTxPoolSize 1000000000 \
  --archiver \
  --node \
  --sequencer

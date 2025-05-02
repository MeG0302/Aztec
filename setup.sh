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
echo -e "${PURPLE}${BOLD}#       Welcome to RetardMeG Node Setup    #${RESET}"
echo -e "${PURPLE}${BOLD}#    Auto-Aztec Alpha Testnet Installer    #${RESET}"
echo -e "${PURPLE}${BOLD}#                                          #${RESET}"
echo -e "${PURPLE}${BOLD}############################################${RESET}\n"
echo -e "${LIGHTBLUE}${BOLD}Twitter: https://x.com/Jaishiva0302${RESET}"
echo -e "${LIGHTBLUE}${BOLD}Telegram: https://t.me/vampsairdrop${RESET}\n"

# === Update and install dependencies ===
echo -e "\n${CYAN}${BOLD}---- UPDATING SYSTEM AND INSTALLING DEPENDENCIES ----${RESET}\n"
sudo apt-get update && sudo apt-get upgrade -y

sudo apt install -y \
  curl iptables build-essential git wget lz4 jq make gcc nano \
  automake autoconf tmux htop nvme-cli libgbm1 pkg-config \
  libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

# === Remove old container tools ===
echo -e "\n${CYAN}${BOLD}---- REMOVING OLD CONTAINER TOOLS ----${RESET}\n"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
  sudo apt-get remove -y $pkg || true
  done

# === Install Docker ===
echo -e "\n${CYAN}${BOLD}---- INSTALLING DOCKER ----${RESET}\n"
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
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo modprobe overlay
sudo modprobe br_netfilter

sudo systemctl daemon-reexec
sudo systemctl enable docker
sudo systemctl restart docker || {
  echo -e "${RED}${BOLD}Docker failed to start. Check logs with: journalctl -xeu docker.service${RESET}"
  exit 1
}

# === Test Docker ===
echo -e "\n${CYAN}${BOLD}---- TESTING DOCKER ----${RESET}\n"
sudo docker run hello-world || true

# === Install Aztec Node ===
echo -e "\n${CYAN}${BOLD}---- INSTALLING AZTEC NODE ----${RESET}\n"
bash -i <(curl -s https://install.aztec.network)

# === Prompt for User Input ===
echo -e "\n${CYAN}${BOLD}---- CONFIGURATION ----${RESET}\n"
echo -e "${LIGHTBLUE}${BOLD}Visit ${PURPLE}https://dashboard.alchemy.com/apps${RESET}${LIGHTBLUE}${BOLD} or ${PURPLE}https://developer.metamask.io/register${RESET}${LIGHTBLUE}${BOLD} to get a Sepolia RPC URL.${RESET}"
read -p "Enter Your Sepolia Ethereum RPC URL: " RPC_URL

echo -e "\n${LIGHTBLUE}${BOLD}Visit ${PURPLE}https://chainstack.com/global-nodes${RESET}${LIGHTBLUE}${BOLD} to get a beacon RPC URL.${RESET}"
read -p "Enter Your Sepolia Ethereum BEACON URL: " BEACON_URL

read -p "Enter your validator private key (with 0x): " SEQUENCER_KEY
read -p "Enter your coinbase address (with 0x): " COINBASE_ADDR

IP=$(curl -s https://api.ipify.org || curl -s http://checkip.amazonaws.com || curl -s https://ifconfig.me)
if [ -z "$IP" ]; then
  echo -e "${RED}${BOLD}Could not determine IP. Please enter manually.${RESET}"
  read -p "Enter your public IP: " IP
fi

# === Firewall setup ===
echo -e "\n${CYAN}${BOLD}---- CONFIGURING FIREWALL ----${RESET}\n"
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

# === Start Aztec node in screen ===
echo -e "\n${CYAN}${BOLD}---- STARTING AZTEC NODE ----${RESET}\n"
cat > $HOME/start_aztec_node.sh << EOL
#!/bin/bash
export PATH=\$PATH:\$HOME/.aztec/bin
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --port 8080 \
  --l1-rpc-urls $RPC_URL \
  --l1-consensus-host-urls $BEACON_URL \
  --sequencer.validatorPrivateKey $SEQUENCER_KEY \
  --sequencer.coinbase $COINBASE_ADDR \
  --p2p.p2pIp $IP
EOL

chmod +x $HOME/start_aztec_node.sh
screen -dmS aztec $HOME/start_aztec_node.sh

echo -e "\n${GREEN}${BOLD}Aztec node started successfully in a screen session.${RESET}\n"

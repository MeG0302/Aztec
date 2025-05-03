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
if ! command -v docker &> /dev/null; then
  echo -e "${LIGHTBLUE}${BOLD}Docker not found. Installing Docker...${RESET}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo usermod -aG docker $USER
  rm get-docker.sh
  echo -e "${GREEN}${BOLD}Docker installed successfully!${RESET}"
fi

# === Docker group membership ===
if ! getent group docker > /dev/null; then
  sudo groupadd docker
fi

sudo usermod -aG docker $USER

if [ -S /var/run/docker.sock ]; then
  sudo chmod 666 /var/run/docker.sock
  echo -e "${GREEN}${BOLD}Docker socket permissions updated.${RESET}"
else
  echo -e "${RED}${BOLD}Docker socket not found. Docker daemon might not be running.${RESET}"
  echo -e "${LIGHTBLUE}${BOLD}Starting Docker daemon...${RESET}"
  sudo systemctl start docker
  sudo chmod 666 /var/run/docker.sock
fi

if docker info &>/dev/null; then
  echo -e "${GREEN}${BOLD}Docker is now working without sudo.${RESET}"
else
  echo -e "${RED}${BOLD}Failed to configure Docker to run without sudo. Using sudo for Docker commands.${RESET}"
  DOCKER_CMD="sudo docker"
fi

# === Install Aztec Node ===
echo -e "${CYAN}${BOLD}---- INSTALLING AZTEC TOOLKIT ----${RESET}"
if ! command -v aztec >/dev/null 2>&1; then
    curl -fsSL https://install.aztec.network | bash
    echo -e "${GREEN}${BOLD}Aztec Toolkit installed successfully!${RESET}"
else
    echo -e "${GREEN}${BOLD}Aztec Toolkit already installed.${RESET}"
fi

aztec-up alpha-testnet

# === Add Aztec to PATH if not present ===
if ! grep -Fxq 'export PATH=$PATH:/root/.aztec/bin' "$HOME/.bashrc"; then
    echo 'export PATH=$PATH:/root/.aztec/bin' >> "$HOME/.bashrc"
    echo -e "${GREEN}${BOLD}Added Aztec to PATH in .bashrc${RESET}"
fi

# === Ensure PATH is updated ===
source "$HOME/.bashrc"

# === Determine Public IP ===
IP=$(curl -s https://api.ipify.org || curl -s http://checkip.amazonaws.com || curl -s https://ifconfig.me)
if [ -z "$IP" ]; then
  echo -e "${RED}${BOLD}Could not determine IP. Please enter manually.${RESET}"
  read -p "Enter your public IP: " IP
fi

# === Prompt for User Input ===
echo -e "${LIGHTBLUE}${BOLD}Visit ${PURPLE}https://dashboard.alchemy.com/apps${RESET}${LIGHTBLUE}${BOLD} to get a Sepolia RPC URL.${RESET}"
read -p "Enter Sepolia Ethereum RPC URL: " RPC_URL

echo -e "\n${LIGHTBLUE}${BOLD}Visit ${PURPLE}https://chainstack.com/global-nodes${RESET}${LIGHTBLUE}${BOLD} to get a beacon RPC URL.${RESET}"
read -p "Enter Sepolia Ethereum BEACON URL: " BEACON_URL

read -p "Enter validator private key (with 0x): " SEQUENCER_KEY
read -p "Enter wallet address (same wallet which you just shared private key above) [with 0x]: " COINBASE_ADDR

# === Port Availability Check ===
echo -e "${CYAN}${BOLD}---- CHECKING PORT AVAILABILITY ----${RESET}"
if netstat -tuln | grep -q ":8080 "; then
    echo -e "${LIGHTBLUE}${BOLD}Port 8080 is in use. Attempting to free it...${RESET}"
    sudo fuser -k 8080/tcp
    sleep 2
    echo -e "${GREEN}${BOLD}Port 8080 has been freed successfully.${RESET}"
else
    echo -e "${GREEN}${BOLD}Port 8080 is available.${RESET}"
fi

# === Firewall setup ===
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 40400
sudo ufw allow 8080
sudo ufw --force enable

# === Start Aztec Node in screen ===
echo -e "${CYAN}${BOLD}---- STARTING AZTEC NODE ----${RESET}"

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

echo -e "${GREEN}${BOLD}Aztec node started successfully in a screen session.${RESET}\n"

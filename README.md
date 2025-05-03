# Aztec Sequencer Node by MeG
![Screenshot 2025-05-03 061130](https://github.com/user-attachments/assets/e45f7e9c-6897-43c6-b085-461d9a250b5f)

# 🐦 Socials
Twitter -  https://x.com/Jaishiva0302

elegram - https://t.me/vampsairdrop
#


# 🛠️ Prerequisites
Ensure your system meets the following requirements:

Operating System: Linux (Ubuntu 20.04+ recommended)

Hardware:

CPU: 8 cores

RAM: 8GB (Min) 16 GB (recomanded)

Storage: 100 GB SSD

Software:

Docker: Installed and running

Node.js: Version 18.x (use nvm for installation)

# 💻 VPS 

If you're looking to rent a VPS, check out Contabo. They offer great options:

VPS Options: https://contabo.com/en/vps/
4.5 Euro or 7 Euro (Recommended for the setup)
#
#
![Screenshot 2025-04-27 211323](https://github.com/user-attachments/assets/5f91f1b9-a114-4d3d-812f-a6830532191b)
#
#

# 🖥️ INSTALLATION 

1) Update 
```bash
sudo apt update && sudo apt upgrade -y
```
2) Run it to set up your Aztec node
```bash
curl -O https://raw.githubusercontent.com/MeG0302/Aztec/main/setup.sh && chmod +x setup.sh && ./setup.sh
```
This command will:
> Download the setup script
> > Make it executable

#


3) Check logs
```bash
sudo docker logs -f $(sudo docker ps -q --filter ancestor=aztecprotocol/aztec:latest | head -n 1)
```

# 🪩 Get the role in discord
join discord here - https://discord.gg/aztec
type the following command in this Discord server: /operator start

come back to vps.


Step 1: Get the latest proven block number:
```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://localhost:8080 | jq -r ".result.proven.number"
```
Save this block number
it should be like : 20791 etc

Step 2: Generate your sync proof
```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["BLOCK_NUMBER","BLOCK_NUMBER"],"id":67}' \
http://localhost:8080 | jq -r ".result"
```

> Change "BLOCK_NUMBER" in both place with the output you got in above step (step 1)
> > paste command in vps


PASTE ALL THESE IN DISCORD

![photo_2025-05-03_06-51-48](https://github.com/user-attachments/assets/cf6ca566-9bea-4095-bb6c-8c351428c09e)

# ®️ Register as Validator

Replace SEPOLIA-RPC-URL , YOUR-PRIVATE-KEY , YOUR-VALIDATOR-ADDRESS with actual value and then execute this command
```bash
aztec add-l1-validator \
  --l1-rpc-urls SEPOLIA-RPC-URL \
  --private-key YOUR-PRIVATE-KEY \
  --attester YOUR-VALIDATOR-ADDRESS \
  --proposer-eoa YOUR-VALIDATOR-ADDRESS \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111
```
NOTE: If you encounter an error like ValidatorQuotaFilledUntil while trying to register as a validator, it means the daily quota has already been reached. do it again after 1 AM UTC

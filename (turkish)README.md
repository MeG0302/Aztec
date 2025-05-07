# Aztec Sequencer Node - MeG Tarafından

![Screenshot 2025-05-03 061130](https://github.com/user-attachments/assets/e45f7e9c-6897-43c6-b085-461d9a250b5f)

# 🐦 Sosyal Medya

Twitter -  [https://x.com/Jaishiva0302](https://x.com/Jaishiva0302)
Telegram - [https://t.me/vampsairdrop](https://t.me/vampsairdrop)

# 🛠️ Gereksinimler

Sisteminizin aşağıdaki gereksinimleri karşladığından emin olun:

İşletim Sistemi: Linux (Ubuntu 20.04+ önerilir)

Donanım:

* İşlemci: 8 çekirdek
* RAM: 8GB (Minimum), 16GB (Tavsiye edilir)
* Depolama: 100 GB SSD

Yazılım:

* Docker: Kurulu ve çalışır durumda
* Node.js: Sürüm 18.x (kurulum için nvm kullanın)

# 💻 VPS

Eğer bir VPS kiralamak istiyorsanız, Contabo'ya göz atabilirsiniz:

VPS Seçenekleri: [https://contabo.com/en/vps/](https://contabo.com/en/vps/)
4.5 Euro veya 7 Euro (Tavsiye edilen)

![Screenshot 2025-04-27 211323](https://github.com/user-attachments/assets/5f91f1b9-a114-4d3d-812f-a6830532191b)

# 🖥️ KURULUM

Bir ETH cüzdanı oluşturun ve adresini ve özel anahtarını kaydedin.

> Cüzdanınıza SEPOLIA \$ETH gönderin.
> Testnet ETH için takas sitesi: [https://testnetbridge.com/sepolia](https://testnetbridge.com/sepolia)

### Ekran Oluştur

```bash
screen -S aztec
```

### 1) Sistem Güncellemesi

```bash
sudo apt update && sudo apt upgrade -y
```

### 2) Aztec Node Kurulumu

```bash
curl -O https://raw.githubusercontent.com/MeG0302/Aztec/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

Bu komut:

> Kurulum betiğini indirir
>
> > Çalıştırılabilir yapar

### 3) Logları Kontrol Et

```bash
sudo docker logs -f $(sudo docker ps -q --filter ancestor=aztecprotocol/aztec:latest | head -n 1)
```

# �� Discord Rolü Al

Discord: [https://discord.gg/aztec](https://discord.gg/aztec)
Sunucuda şu komutu girin: `/operator start`

Ardından VPS'ye geri dönün.

> Node başlatıldıktan sonra 10-20 dakika bekleyin.

### Adım 1: En son ispatlanmış blok numarasını alın

```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://localhost:8080 | jq -r ".result.proven.number"
```

Blok numarasını kaydedin (20791 gibi bir şey olacak).

### Adım 2: Senkronizasyon Kanıtı Oluştur

```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["BLOCK_NUMBER","BLOCK_NUMBER"],"id":67}' \
http://localhost:8080 | jq -r ".result"
```

> "BLOCK\_NUMBER" kısmını yukarıdaki adımdan aldığınız blok numarasıyla değiştirin.
>
> > VPS'de komutu çalıştırın.

Bu verileri Discord'a yapıştırın.

![photo\_2025-05-03\_06-51-48](https://github.com/user-attachments/assets/cf6ca566-9bea-4095-bb6c-8c351428c09e)

# ®️ Doğrulayıcı Olarak Kaydolun

SEPOLIA-RPC-URL , YOUR-PRIVATE-KEY , YOUR-VALIDATOR-ADDRESS değerlerini kendi bilgilerinizle değiştirin:

```bash
aztec add-l1-validator \
  --l1-rpc-urls SEPOLIA-RPC-URL \
  --private-key YOUR-PRIVATE-KEY \
  --attester YOUR-VALIDATOR-ADDRESS \
  --proposer-eoa YOUR-VALIDATOR-ADDRESS \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111
```

NOT: Eğer "ValidatorQuotaFilledUntil" gibi bir hata alırsanız, bu günlük kayıt kotasının dolduğu anlamına gelir. Gece 01:00 UTC'den sonra tekrar deneyin.

# ⬆️ GÜNCELLEME

### 1. Önceki node'u durdurun

```bash
docker stop $(docker ps -q --filter "ancestor=aztecprotocol/aztec") && docker rm $(docker ps -a -q --filter "ancestor=aztecprotocol/aztec")
```

### 2. Aztec ekranını kapatın

```bash
screen -ls | grep -i aztec | awk '{print $1}' | xargs -I {} screen -X -S {} quit
```

### 3. Node'u güncelleyin

```bash
aztec-up alpha-testnet
```

### 4. Önceki verileri silin

```bash
rm -rf ~/.aztec/alpha-testnet/data/
```

### 5. Node'u yeniden başlatın

```bash
curl -O https://raw.githubusercontent.com/MeG0302/Aztec/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

### 6. Logları tekrar kontrol edin

```bash
sudo docker logs -f $(sudo docker ps -q --filter ancestor=aztecprotocol/aztec:latest | h
```

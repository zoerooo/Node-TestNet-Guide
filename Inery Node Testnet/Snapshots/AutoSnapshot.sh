# Install zip unzip
sudo apt update
sleep 2

# Download Snapshots Inery
wget --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://drive.google.com/uc?export=download&id=1VvgvVtI1iJa81-bYIIhPDGQiwBwrocSp' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1VvgvVtI1iJa81-bYIIhPDGQiwBwrocSp" -O blockchain.tar.gz && rm -rf /tmp/cookies.txt && mkdir -p $HOME/blockchain && tar -xvzf blockchain.tar.gz -C blockchain/ && rm blockchain.tar.gz
sleep 1

# Stop Inery Node
cd $HOME/inery-node/inery.setup/master.node/
./stop.sh
sleep 2

# Remove File
rm -rf $HOME/inery-node/inery.setup/master.node/blockchain
sleep 1

# Masukkan folder snapshots yang baru ke Inery
mkdir -p $HOME/inery-node/inery.setup/master.node/blockchain
mv -i $HOME/blockchain/* $HOME/inery-node/inery.setup/master.node/blockchain/
source ~/.bashrc && which nodine || source ~/.bash_profile
sleep 2

# Restart Inery Node
cd $HOME/inery-node/inery.setup/master.node/
sleep 1
./genesis_start.sh
./start.sh
sleep 1

# Pastikan Lagi
cd $HOME/inery-node/inery.setup/master.node/
sleep 1
./genesis_start.sh
./start.sh
sleep 1

# Remove Installasi
cd ~
rm -rf $HOME/AutoSnapshot.sh

# Check Log
cd $HOME/inery-node/inery.setup/master.node/ && tail -f blockchain/nodine.log

# End

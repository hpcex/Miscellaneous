apt install -y gpg
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee -a /etc/apt/sources.list.d/gierens.list
apt update
apt install -y eza
echo -e 'alias ls="eza --icons"\nalias ll="eza --time-style=long-iso --icons --binary -lhg"\nalias tree="eza --tree --icons"' >> ~/.bashrc
source ~/.bashrc

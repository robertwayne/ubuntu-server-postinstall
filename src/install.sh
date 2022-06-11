# This script is meant to be run after a fresh install of the latest Ubuntu server version.
# It will install the following packages:
# - Rust
# - Node
# - Nginx
# - PostgreSQL
# - Redis Server
# - CrowdSec
# - SSH
#
# A firewall will be configured for SSH only.

# Ensure we're up to date.
sudo apt update -y && sudo apt upgrade -y

# Set aliases.
echo -e "\n# Aliases added automatically by ubuntu-server-postinstall" >> ~/.bashrc
echo -e "\nalias python=python3" >> ~/.bashrc

# Disable MOTD News.
sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news

# Set up basic firewall.
sudo ufw allow OpenSSH
sudo ufw --force enable

# Add keyring directory for GPG keys.
sudo mkdir /usr/local/share/keyrings

# Install Rust on the nightly compiler.
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile default -y
source $HOME/.cargo/env

# Install nvm and Node.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm" && \. "$NVM_DIR/nvm.sh"
nvm install node

# Add PostgreSQL 14 repository and keyring.
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc > ~/postgres.key

gpg --no-default-keyring --keyring ./temp-keyring.gpg --import postgres.key
gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output postgres.gpg

sudo mv postgres.gpg /usr/local/share/keyrings

sudo sed -i 's@deb @deb [signed-by=/usr/local/share/keyrings/postgres.gpg] @g' /etc/apt/sources.list.d/pgdg.list

# Add Redis Server repository and keyring.
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/local/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/local/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

# Add CrowdSec repository.
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash

# Install packages.
sudo apt update -y
sudo apt install -y build-essential postgresql-14 redis nginx crowdsec

# Disable root login.
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Clean up.
sudo rm temp-keyring.gpg temp-keyring.gpg~ postgres.key
sudo apt autoremove -y

# Finish message.
clear
echo "\`ubuntu-server-postinstall\` script complete!"
echo "Some things to do next: disable passwords and set up SSH keys, fine-tune the firewall via \`ufw\`, and consider other hardening options (\`sudo apt install lynis\` for system-wide and container auditing)."
echo "In addition, you should consider `sudo reboot` to ensure that all changes have been applied and/or all your services have been properly restarted."
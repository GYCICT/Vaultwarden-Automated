#!/bin/bash

# Check if root
user=$(whoami)
if [[ "$user" != "root" ]];
then
	echo "Error: Must be run as root or run with SUDO"
	exit
fi

# Install dependacies 
apt-get -y install \
ranger \
net-tools \
apt-transport-https \
curl \
ca-certificates \
gnupg \
lsb-release

# Stop apache2
systemctl stop apache2
systemctl disable apache2

# Docker install (https://www.docker.com/)
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io

# Portainer Install (https://www.portainer.io/)
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=no -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Docker compose (https://docs.docker.com/compose/)
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Nginx Proxy Manager (https://nginxproxymanager.com/)
# LetsEncrypt won't work due to port 80 not being exposed on this yml
# To get letsencrypt to work, you will need to follow this guide. (https://github.com/gorgdel/Vaultwarden-Automated) 
mkdir /opt/nginxproxymanager
cd /opt/nginxproxymanager
curl -L "https://raw.githubusercontent.com/GYCICT/Vaultwarden-Automated/master/docker-compose.yml" --output docker-compose.yml
docker-compose up -d
cd

# Vaultwarden (https://github.com/dani-garcia/vaultwarden)
docker pull vaultwarden/server:latest
docker run -d --name vaultwarden --restart=always -v /vw-data/:/data/ -p 80:80 vaultwarden/server:latest
clear
echo "Complete - Proceed with other steps."
sleep 0.5 
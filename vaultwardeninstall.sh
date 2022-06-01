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

# Vaultwarden (https://github.com/dani-garcia/vaultwarden)
docker pull vaultwarden/server:latest
docker run -d --name vaultwarden \
--restart=always \
-e ROCKET_TLS='{certs="/ssl/cert.pem",key="/ssl/priv.key"}' \
-v /ssl/:/ssl/ \
-v /vw-data/:/data/ \
-p 443:80 \
vaultwarden/server:latest

echo "Complete - Proceed with other steps."
sleep 0.5 

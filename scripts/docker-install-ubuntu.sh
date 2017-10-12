#!/usr/bin/env bash
set -e

# Tested with Google and Digital Ocean Ubuntu 16.04 LTS Virtual Machines
#
#
# You can run this startup script manually, by copying it to the host,
# or by issuing this curl command. Since this command pipes the script
# directly into a bash shell you should examine the script before running.
#
#   curl -sSL https://cdn.rawgit.com/chainpoint/chainpoint-node/58a84a8822b8d79b1041c4fcf1d6e5d8e2fc431a/scripts/docker-install-ubuntu.sh | bash
#
# Digital Ocean provides good documentation on how to manually install
# Docker on their platform.
#
#   https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
#
# Pre-requisites:
# - 64-bit Ubuntu 16.04 server
# - Non-root user with sudo privileges
#

echo '#################################################'
echo 'Installing Docker'
echo '#################################################'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce make

echo '#################################################'
echo 'Allow current user to use Docker without "sudo"'
echo 'REQUIRES SSH session logout + login'
echo '#################################################'
sudo usermod -aG docker ${USER}

echo '#################################################'
echo 'Installing Docker Compose'
echo '#################################################'
sudo mkdir -p /usr/local/bin
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.16.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo '#################################################'
echo 'Downloading chainpoint-node Github Repository'
echo '#################################################'
if [ ! -d "~/chainpoint-node" ]; then
  cd ~ && git clone https://github.com/chainpoint/chainpoint-node
fi

echo '#################################################'
echo 'Creating .env config file from .env.sample'
echo '#################################################'
cd ~/chainpoint-node && make build-config

echo '#################################################'
echo 'Docker and docker-compose installation completed!'
echo 'Please now exit and restart this SSH session'
echo 'before continuing with the README instructions.'
echo '#################################################'

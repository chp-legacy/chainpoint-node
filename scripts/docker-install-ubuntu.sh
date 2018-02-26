#!/usr/bin/env bash
set -e

# Tested with Google and Digital Ocean Ubuntu 16.04 LTS Virtual Machines
#
#
# You can run this startup script manually, by copying it to the host,
# or by issuing this curl command. Since this command pipes the script
# directly into a bash shell you should examine the script before running.
#
#   curl -sSL https://cdn.rawgit.com/chainpoint/chainpoint-node/c1f65f79a831caae2ccadac2568620867dd80e1a/scripts/docker-install-ubuntu.sh | bash
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

# Don't run this script more than once!
if [ -f /.chainpoint-installer-run ]; then
    echo "Looks like this script has already been run. Exiting!"
    exit 0
fi

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
  cd ~ && git clone -b master https://github.com/chainpoint/chainpoint-node
fi

echo '#################################################'
echo 'Creating .env config file from .env.sample'
echo '#################################################'
cd ~/chainpoint-node && make build-config

echo '#################################################'
echo 'Creating swap file as needed'
echo '#################################################'

if free | awk '/^Swap:/ {exit !$2}'; then
    echo "An existing swap file was detected. Skipping..."
else
    echo "No swap file detected. Installing..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    sudo sysctl vm.swappiness=10
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    sudo sysctl vm.vfs_cache_pressure=50
    echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
fi

echo '#################################################'
echo 'Docker and docker-compose installation completed!'
echo 'Please now exit and restart this SSH session'
echo 'before continuing with the README instructions.'
echo '#################################################'

sudo touch /.chainpoint-installer-run

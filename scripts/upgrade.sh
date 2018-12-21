#!/usr/bin/env bash
set -e

# Copyright 2018 Tierion
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# You can run this upgrade script manually, by copying it to the host,
# or by issuing this curl command. Since this command pipes the script
# directly into a bash shell you should examine the script before running.
#
#   curl -sSL https://chainpoint-node.storage.googleapis.com/upgrade.sh | bash
#

# Don't run if seemingly outside of chainpoint-node dir.
if [ -f /docker-compose.yaml ]; then
    echo "This script should be run in the chainpoint-node dir. Exiting!"
    exit 0
fi

echo '#################################################'
echo 'Ensure Node is running on supported OS'
echo '#################################################'

if [ "$(. /etc/os-release; echo $NAME)" != "Ubuntu" ]; then
  echo "Looks like you are not running this on an Ubuntu OS. Exiting!"
  exit 1
fi

echo '#################################################'
echo 'Bring down existing Node and any orphans'
echo '#################################################'

docker-compose down --remove-orphans

echo '#################################################'
echo 'Clear old chainpoint-containers'
echo '#################################################'

containers=$(docker ps -aq -f "label=org.chainpoint.service");
if [ "${containers}" != "" ]; then
    echo "flushing docker containers...";
    docker stop ${containers};
    docker rm ${containers};
fi

echo '#################################################'
echo 'Upgrade docker-compose as needed'
echo '#################################################'

sudo mkdir -p /usr/local/bin
curl -sSL https://chainpoint-node.storage.googleapis.com/docker-compose-install.sh | bash

echo '#################################################'
echo 'Pull latest Node code from git master branch'
echo '#################################################'

git fetch && git checkout master && git pull

echo '#################################################'
echo 'Fix keys dir permissions as needed'
echo '#################################################'

sudo chown -R root keys && sudo chmod 777 keys && sudo chmod 777 keys/backups

echo '#################################################'
echo 'Fix .data dir permissions as needed'
echo '#################################################'

sudo mkdir -p .data/rocksdb && sudo chown root .data/rocksdb && sudo chmod 777 .data/rocksdb

echo '#################################################'
echo 'Generate new self-signed TLS cert as needed for 127.0.0.1'
echo '#################################################'
rm -rf cert.*
[ ! -f ./cert.key ] && ./certgen.sh 127.0.0.1

echo '#################################################'
echo 'Start ntpd service container if needed'
echo '#################################################'

make ntpd-start

echo '#################################################'
echo 'Start upgraded Node'
echo '#################################################'

export COMPOSE_IGNORE_ORPHANS=true
docker-compose up -d

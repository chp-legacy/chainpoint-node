#!/bin/bash

curl -s -L "https://storage.googleapis.com/chainpoint-node/docker-compose.tar.gz" -o /tmp/docker-compose.tar.gz && cd /tmp && tar -zxvf docker-compose.tar.gz && sudo mv -f /tmp/docker-compose /usr/local/bin/docker-compose && sudo chown root /usr/local/bin/docker-compose && sudo chmod a+rx /usr/local/bin/docker-compose



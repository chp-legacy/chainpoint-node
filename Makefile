# First target in the Makefile is the default.
all: help

# without this 'source' won't work.
SHELL := /bin/bash

# Get the location of this makefile.
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Specify the binary dependencies
REQUIRED_BINS := docker docker-compose
$(foreach bin,$(REQUIRED_BINS),\
    $(if $(shell command -v $(bin) 2> /dev/null),$(),$(error Please install `$(bin)` first!)))

.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## up                        : Start Node
.PHONY : up
up: guard-ubuntu ntpd-start build-rocksdb
	@export COMPOSE_IGNORE_ORPHANS=true; docker-compose up -d

## down                      : Shutdown Node
.PHONY : down
down: ntpd-stop
	@export COMPOSE_IGNORE_ORPHANS=true; docker-compose down

## restart                   : Restart only chainpoint-node service
.PHONY : restart
restart:
	@export COMPOSE_IGNORE_ORPHANS=true; docker-compose restart chainpoint-node

## restart-all               : Restart all services
.PHONY : restart-all
restart-all: down up

## logs                      : Tail Node logs
.PHONY : logs
logs:
	@docker-compose logs -f -t | awk '/chainpoint-node/ && !(/DEBUG/ || /failed with exit code 99/ || /node server\.js/ || /yarnpkg\.com/)'

## logs-ntpd                 : Tail ntpd logs
.PHONY : logs-ntpd
logs-ntpd:
	@docker-compose -f docker-compose-ntpd.yaml logs -f -t | awk '/chainpoint-ntpd/'

## logs-redis                : Tail Redis logs
.PHONY : logs-redis
logs-redis:
	@docker-compose logs -f -t | awk '/redis/'

## logs-postgres             : Tail PostgreSQL logs
.PHONY : logs-postgres
logs-postgres:
	@docker-compose logs -f -t | awk '/postgres/'

## logs-all                  : Tail all logs
.PHONY : logs-all
logs-all:
	@docker-compose logs -f -t

## ps                        : View running processes
.PHONY : ps
ps:
	@docker-compose ps

## build-config              : Create new `.env` config file from `.env.sample`
.PHONY : build-config
build-config:
	@[ ! -f ./.env ] && \
	cp .env.sample .env && \
	echo 'Copied config .env.sample to .env' || true

## git-fetch                 : Git fetch latest
.PHONY : git-fetch
git-fetch:
	git fetch && git checkout master && git pull

## upgrade                   : Stop all, git pull, upgrade docker-compose, and start all
.PHONY : upgrade
upgrade: down git-fetch clear-containers guard-ubuntu upgrade-docker-compose up

guard-ubuntu:
	@os=$$(lsb_release -si); \
	if [ "$${os}" != "Ubuntu" ]; then \
		echo "*********************************************************"; \
		echo "WARNING : Unsupported OS. Ubuntu 16.04 LTS is supported."; \
		echo "*********************************************************"; \
	fi

## clear-containers          : Stop and remove any running Chainpoint Docker containers
.PHONY : clear-containers
clear-containers:
	@-containers=$$(docker ps -aq -f "label=org.chainpoint.service"); \
	if [ "$${containers}" != "" ]; then \
		echo "flushing docker containers..."; \
		docker stop $${containers}; \
		docker rm $${containers}; \
	fi

## upgrade-docker-compose    : Upgrade local docker-compose installation
.PHONY : upgrade-docker-compose
upgrade-docker-compose:
	@sudo mkdir -p /usr/local/bin; \
	curl -sSL https://chainpoint-node.storage.googleapis.com/docker-compose-install.sh | bash

## postgres                  : Connect to the local PostgreSQL with `psql`
.PHONY : postgres
postgres:
	@export COMPOSE_IGNORE_ORPHANS=true; docker-compose up -d postgres
	@sleep 6
	@docker exec -it postgres-node psql -U chainpoint

## redis                     : Connect to the local Redis with `redis-cli`
.PHONY : redis
redis:
	@export COMPOSE_IGNORE_ORPHANS=true; docker-compose up -d redis
	@sleep 2
	@docker exec -it redis-node redis-cli

# DEPRECATED : Will still work for now, remove after 7/1/2018.
.PHONY : auth-keys
auth-keys: backup-auth-keys
	@echo -n "WARNING : 'make auth-keys' is deprecated. Please use 'make backup-auth-keys' instead."

## backup-auth-keys          : Backup HMAC Auth keys to the 'keys/backups' dir
.PHONY : backup-auth-keys
backup-auth-keys: up
	@docker exec -it chainpoint-node node auth-keys-backup.js

## print-auth-keys           : Print to console the filename and contents of auth key (HMAC) backups
.PHONY : print-auth-keys
print-auth-keys: up
	@docker exec -it chainpoint-node node auth-keys-print.js

## calendar-delete           : Delete all calendar data for this Node
.PHONY : calendar-delete
calendar-delete:
	@export COMPOSE_IGNORE_ORPHANS=true; docker-compose up -d postgres
	@sleep 6
	@docker exec -it postgres-node psql -U chainpoint -c "DELETE FROM calendar"
	make restart

.PHONY : sign-chainpoint-security-txt
sign-chainpoint-security-txt:
	gpg --armor --output chainpoint-security.txt.sig --detach-sig chainpoint-security.txt

## ntpd-start                : Start docker ntpd
.PHONY : ntpd-start
ntpd-start:
	@status=$$(ps -ef | grep -v -E '(grep|ntpd-start)' | grep -E '(ntpd|timesyncd|timed|pacemaker)' | wc -l); \
	if test $${status} -ge 1; then \
		echo "Local time sync daemon seems to be running. Skipping chainpoint-ntpd..."; \
	else \
		echo "Local time sync daemon does not appear to be running. Starting chainpoint-ntpd.."; \
		export COMPOSE_IGNORE_ORPHANS=true; docker-compose -f docker-compose-ntpd.yaml up -d; \
	fi

## ntpd-stop                 : Stop docker ntpd
.PHONY : ntpd-stop
ntpd-stop:
	-@export COMPOSE_IGNORE_ORPHANS=true; docker-compose -f docker-compose-ntpd.yaml down;

## ntpd-status               : Show docker ntpd status
.PHONY : ntpd-status
ntpd-status:
	@echo ''
	@docker exec -it chainpoint-ntpd ntpctl -s all

# private target. Upload the installer shell script to a common location.
.PHONY : upload-installer
upload-installer:
	gsutil cp scripts/setup.sh gs://chainpoint-node/setup.sh
	gsutil acl ch -u AllUsers:R gs://chainpoint-node/setup.sh
	gsutil setmeta -h "Cache-Control:private, max-age=0, no-transform" gs://chainpoint-node/setup.sh

# private target. Upload the docker compose installer shell script to a common location.
.PHONY : upload-docker-compose-installer
upload-docker-compose-installer:
	gsutil cp docker-compose-install.sh gs://chainpoint-node/docker-compose-install.sh
	gsutil acl ch -u AllUsers:R gs://chainpoint-node/docker-compose-install.sh
	gsutil setmeta -h "Cache-Control:private, max-age=0, no-transform" gs://chainpoint-node/docker-compose-install.sh

	gsutil cp docker-compose.tar.gz gs://chainpoint-node/docker-compose.tar.gz
	gsutil acl ch -u AllUsers:R gs://chainpoint-node/docker-compose.tar.gz
	gsutil setmeta -h "Cache-Control:private, max-age=0, no-transform" gs://chainpoint-node/docker-compose.tar.gz

# private target. Ensure the RocksDB data dir exists before
# it gets mounted into the container as a volume.
.PHONY : build-rocksdb
build-rocksdb:
	@os=$$(lsb_release -si); \
	if [ "$${os}" = "Ubuntu" ]; then \
		sudo mkdir -p .data/rocksdb && sudo chown root .data/rocksdb && sudo chmod 777 .data/rocksdb; \
	else \
		mkdir -p .data/rocksdb && chmod 777 .data/rocksdb; \
	fi

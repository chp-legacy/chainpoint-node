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

## up              : Start Node
.PHONY : up
up:
	@docker-compose up -d

## down            : Shutdown Node
.PHONY : down
down:
	@docker-compose down

## restart         : Restart Node
.PHONY : restart
restart: down up

## logs            : Tail Node logs
.PHONY : logs
logs:
	@docker-compose logs -f -t | grep chainpoint-node

## logs-redis      : Tail Redis logs
.PHONY : logs-redis
logs-redis:
	@docker-compose logs -f -t | grep redis

## logs-postgres   : Tail PostgreSQL logs
.PHONY : logs-postgres
logs-postgres:
	@docker-compose logs -f -t | grep postgres

## logs-all        : Tail all logs
.PHONY : logs-all
logs-all:
	@docker-compose logs -f -t

## ps              : View running processes
.PHONY : ps
ps:
	@docker-compose ps

## build-config    : Create new `.env` config file from `.env.sample`
.PHONY : build-config
build-config:
	@[ ! -f ./.env ] && \
	cp .env.sample .env && \
	echo 'Copied config .env.sample to .env' || true

## git-pull        : Git pull latest
.PHONY : git-pull
git-pull:
	@git pull

## upgrade         : Same as `make down && git pull && make up`
.PHONY : upgrade
upgrade: down git-pull up

## postgres        : Connect to the local PostgreSQL with `psql`
.PHONY : postgres
postgres:
	@docker-compose up -d postgres
	@sleep 6
	@docker exec -it postgres-node psql -U chainpoint

## redis           : Connect to the local Redis with `redis-cli`
.PHONY : redis
redis:
	@docker-compose up -d redis
	@sleep 2
	@docker exec -it redis-node redis-cli

## auth-keys       : Export HMAC auth keys from PostgreSQL
.PHONY : auth-keys
auth-keys:
	@docker-compose up -d postgres	
	@sleep 6
	@docker exec -it postgres-node psql -U chainpoint -c 'SELECT * FROM hmackeys;'

## auth-key-update : Update HMAC auth key with `KEY` (hex string) var. Example `make auth-key-update KEY=mysecrethexkey`
.PHONY : auth-key-update
auth-key-update: guard-KEY up
	@sleep 6
	@source .env && docker exec -it postgres-node psql -U chainpoint -c "INSERT INTO hmackeys (tnt_addr, hmac_key, version, created_at, updated_at) VALUES (LOWER('$$NODE_TNT_ADDRESS'), LOWER('$(KEY)'), 1, clock_timestamp(), clock_timestamp()) ON CONFLICT (tnt_addr) DO UPDATE SET hmac_key = LOWER('$(KEY)'), version = 1, updated_at = clock_timestamp()"
	make restart

## auth-key-delete : Delete HMAC auth key with `NODE_TNT_ADDRESS` var. Example `make auth-key-delete NODE_TNT_ADDRESS=0xmyethaddress`
.PHONY : auth-key-delete
auth-key-delete: guard-NODE_TNT_ADDRESS up
	@sleep 6
	@docker exec -it postgres-node psql -U chainpoint -c "DELETE FROM hmackeys WHERE tnt_addr = LOWER('$(NODE_TNT_ADDRESS)')"
	make restart

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

.PHONY : sign-chainpoint-security-txt
sign-chainpoint-security-txt:
	gpg --armor --output chainpoint-security.txt.sig --detach-sig chainpoint-security.txt

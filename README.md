# Chainpoint Node

[![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## About

Chainpoint Nodes allows anyone to run a server that accepts hashes, anchors them to public
blockchains, create and verify proofs, and participate in the Tierion Network.

Nodes communicate with the Tierion Core, spending TNT to anchor hashes, and gain eligibility to earn TNT by providing services to the Tierion Network.

To be eligible to earn TNT a Node must:

* register a unique Ethereum address
* maintain a minimum TNT balance for that address
* provide public network services
* pass all audits and health checks from Tierion Core
* have enough credits to send hashes from a Node to Core

Chainpoint Nodes that don't meet these requirements won't be eligible to earn TNT through periodic rewards.

Chainpoint Nodes aggregate incoming hashes into a Merkle tree every second. The Merkle root is submitted to a Tierion Core for anchoring
to public blockchains.

Nodes maintain a mirror of the Calendar. This allows any Node to verify any proof.

Nodes expose a public HTTP API, documented with Swagger, that you can explore:
[https://app.swaggerhub.com/apis/chainpoint/node/1.0.0](https://app.swaggerhub.com/apis/chainpoint/node/1.0.0)

### Important Notice

This document contains instructions for installing and running
a Chainpoint Node. If you are looking for the full source code
for this application see [github.com/chainpoint/chainpoint-node-src](https://github.com/chainpoint/chainpoint-node-src)

## About the Technology

### How Does It Work?

Chainpoint Node is run as a `docker-compose` application. `docker-compose` is a tool for running multiple Docker containers as
an orchestrated application suite.

`docker-compose` allows distribution of binary images that can run
anywhere that Docker can run. This ensures that everyone, regardless of
platform, is running the same code.

Docker makes it easy to distribute and upgrade the Chainpoint Node
software.

### Software Components

When started, `docker-compose` will install and run three system components in the Docker virtual machine.

* PostgreSQL Database
* Redis
* Chainpoint Node (Node.js)

They are started as a group and should not interfere with any other
software systems running on your server.

Each Node instance you want to run will need:

* A dedicated Ethereum address
* Public IP/hostname
* Minimum TNT balance
* Access to credits, purchased with TNT

### System Requirements

The software should be able to be run on any system that supports
the Docker and Docker Compose container management tools and meets the minimal hardware requirements.

#### Hardware

The minimum hardware requirements for running a Node are
relatively low. The following would be suitable minimums
for a Node expecting relatively light traffic:

- `512MB RAM`
- `1 CPU Core`
- `20GB Hard Disk or SSD`
- `Public IPv4 address`

If you are expecting larger volumes of hashes to be sent to your server its recommended that you scale-up the system resources by adding more RAM and CPU cores. Alternatively, you can scale-out horizontally by running more Nodes. The disk storage needs of a Node are relatively small.

It is not currently supported to run multiple Nodes on a single
physical host.

#### Operating System

The software has been tested on the following operating systems:

* `Ubuntu 16.04 LTS`
* `macOS Version 10.12.6`

It will likely run on other operating systems that support Docker
and Docker Compose, but support is not currently provided for those.

#### Docker & Docker Compose

Nodes have been developed and tested to run on the following
software versions.

* `Docker version 17.06.2-ce, build cec0b72`
* `docker-compose version 1.14.0, build c7bdf9e`

## Installation

This software is designed to be simple to install and run
on supported systems. Please follow the instructions below
to get started.

For illustrative purposes, we'll provide instructions for running a Node on Digital Ocean, a cloud VPS provider that gives you root access to a host at minimal monthly cost.

### Prerequisites

Before you start, you will need:

* An Ethereum address that you have the private keys for. Exchange provided accounts are generally not supported. You should be able to unlock your account to send Ether or TNT using MyEtherWallet for example.

* You must have the mimimum balance of TNT to run a Node, and those TNT must be assigned to the Ethereum address you'll
use to identify your Node. You can check your TNT balance
(in Grains, divide by `100000000` (10^8) for TNT balance) using the Etherscan.io
[contract reading tool for our ERC20 smart contract](https://etherscan.io/address/0x08f5a9235b08173b7569f83645d2c7fb55e8ccd8#readContract) (input your address in the `balanceOf` field and click `Query`).

* Sending hashes from a Node to Core requires that you convert TNT to system credits and spend credits for each
hash submitted. You will need additional TNT to send to our system, over and above the minimum balance, to fund your credit balance. Nodes that don't meet both the required minimum balance, and that don't have enough credits to operate for a period of time under normal use, are not eligible for Node discovery or TNT rewards.

### Start a Server

Your first step is to start a server and gain SSH access
to your account on that server. This is beyond the scope of this document. You will need:

* `root` access, or a user with `sudo` priveleges
* Ubuntu 16.04 OS

Log in to your server and continue to the next step.

### Install Docker and Docker Compose

There are [good instructions available](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04) for installing Docker on an Ubuntu server.

There are also [official docs for installing Docker](https://docs.docker.com/engine/installation/) on other systems.

For some systems you will need to separately install `docker-compose`.

To make this process easier we have created a small script that will install Docker, `docker-compose`, and download this
`chainpoint-node` repository to your system with a single command:

```
curl -sSL https://cdn.rawgit.com/chainpoint/chainpoint-node/13b0c1b5028c14776bf4459518755b2625ddba34/scripts/docker-install-ubuntu.sh | bash
```

Since this command runs a shell script as a priviledged user on your system we recommend you [examine it carefully](https://github.com/chainpoint/chainpoint-node/blob/master/scripts/docker-install-ubuntu.sh) before you run it.

Simply copy/paste that script into your terminal and it will:

* install Docker
* install Docker Compose
* grant the ability for your local user to run Docker commands without using `sudo`
* download this repository to your home folder.

**Important**: You should close your terminal and login again now to make sure that the changes in the script are fully applied.

### Configure Your Node

Configuration is as simple as editing a single configuration file and providing two variables. We provide a sample configuration file in this repository called `.env.sample`.

The installation script, if you use it, will copy that file
to `~/chainpoint-node/.env` for you, ready to edit.

If you installed everything manually you will want to:

```
cd ~/chainpoint-node
cp .env.sample .env

# use your favorite editor:
vi .env
```

There are only two values that you may need to edit (comments removed for clarity):

```
NODE_TNT_ADDRESS=
CHAINPOINT_NODE_PUBLIC_URI=
```

`NODE_TNT_ADDRESS` : should be set to your Ethereum address that contains TNT balance. It will start with `0x` and have an additional 40 hex characters (`0-9, a-f, A-F`). This is the unique identifier for your Node.

`CHAINPOINT_NODE_PUBLIC_URI` : should be a URI where your Node can be publicly discovered and utilized by others. This might look like `http://10.1.1.20`. Your Node will run on port `80` over `http`. You can also provide a DNS domain name instead of an IPv4 address if you prefer. If provided, this address will be periodically audited by Tierion Core to ensure compliance with the rules for a healthy Node. If you leave this config value blank, it will be assumed that your Node is not publicly available, and you will not be eligible to earn TNT rewards.

Once your Node starts with these configured values, a secret key will be provided for your system and stored in your local database. The Node will use this key to help authenticate itself to Tierion Core, submitting hashes, and retrieving proofs. If this secret key is lost, you will likely need to switch to another Ethereum address, and any credits on Tierion Core will be inaccessible. When you first start your Node this secret key is displayed in the logs. You will want to store it somewhere in case of accidental deletion.

Loss of this secret does not expose you to loss of Ether or TNT. But without it you may lose any credits you have associated with your Ethereum address.

### Run Your Node

Now its time to start your own Node!

After finishing the configuration in the `.env` file and saving it make sure you are in the `~/chainpoint-node` directory and run `make`. This will show you some Makefile commands that are available to you:

* `make up` : start all services
* `make down` : stop all services
* `make upgrade` : upgrade to newest release
* `make logs` : show, and tail, the `docker-compose` logfiles
* `make ps` : show the status of the running processes

The simplest step at this point is to run `make up`. This
will automatically pull down the appropriate Docker images
(which may take a few minutes the first time, or on slower network systems) and start them. `docker-compose` will also
try to ensure that these services keep running, even if they were to crash (which is unlikely).

### Monitor Your Node

You can run `make ps` to see the services that are running.

You can run `make logs` to tail the logfiles for all `docker-compose` managed services.

When you start your Node you'll see in the logs that your Node will attempt to register itself with one of our Tierion Core clusters and will be provided with a secret key.

The Node will then go through a process of downloading, and cryptographically verifying the entire Calendar. Every block will have its signature checked and will be stored locally. This process may take some time on first run as our Calendar grows. After initial sync, all incremental changes will also be pulled down to every Node, verified and stored.

If there are any problems you see in the logs, or if something is not working as expected, please [file a bug](https://github.com/chainpoint/chainpoint-node/issues) and provide as much information about the issue as possible.

### Transferring TNT for Credits

**Important**: When sending TNT to our Ethererum address in order to purchase credits, please reference our [https://keybase.pub/tierion/chainpoint-security.txt](https://keybase.pub/tierion/chainpoint-security.txt) file. This cryptographically signed document, should be considered the authoritative source of security related information for the Tierion Network. This document, and its signature file, are also found in the root of this repository.

Once your Node is running, and has registered itself,
you'll need to transfer TNT so that you can have a credit
balance for submitting hashes. If your Node has no credits, it won't be able to submit hashes to Core, and it won't be eligible for TNT rewards.

The process of converting TNT to credits is easy. Using a tool like [MyEtherWallet](https://www.myetherwallet.com/), transfer TNT from the address that your Node is registered with, to the Core receiving address.

You can find the current receiving address in the chainpoint-security.txt document referenced above, or in the `/config` HTTP endpoint on each Core cluster.

* https://a.chainpoint.org/config
* https://b.chainpoint.org/config
* https://c.chainpoint.org/config

Just look for the `core_eth_address` key in the JSON that is returned. Always confirm the address here, and confirm the `chainpoint.org` TLS certificate is being used.

Once you've confirmed this address you'll need to send some TNT. Its *very* important that you send the TNT from the *same* address that your Node is registered with. This is the only way we can assign the credits to the correct address.

It is also *very* important to only send the TNT for credits *after* you have successfully setup, run and registered your Node. Otherwise we won't know the address to assign the credits to.

### Sending Hashes to Your Node with the CLI

Now you should be fully up and running! You might want to try out your new Node now with the [Chainpoint CLI](https://github.com/chainpoint/chainpoint-cli).

Normally the CLI will auto-discover a Node to send hashes to. Once you have it installed though, you can configure it to always use your Node if you prefer.

You can either modify the Node address in the `~/.chainpoint/cli.config` to set it permanently, or you can override the Node address every time you use it like this:

```
chp submit --server http://127.0.0.1 <hash>
```

### Stopping Your Node

You can stop your Node at any time with `make down`. You can
verify that everything is stopped with `make ps`.

## Thank You!

Thank you for being an active participant in the Tierion Network and for your interest in running a Chainpoint Node. We couldn't do it without you!

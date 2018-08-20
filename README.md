# Chainpoint Node

[![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Frequently Asked Questions

Need help? Looking for the [FAQ](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions)?

## About

Chainpoint Nodes allows anyone to run a server that accepts hashes, anchors them to public
blockchains, create and verify proofs, and participate in the Chainpoint Network.

Nodes communicate with the Chainpoint Core, spending TNT to anchor hashes, and gain eligibility to earn TNT by providing services to the Chainpoint Network.

To be eligible to earn TNT a Node must:

* register with a unique Ethereum address
* maintain a minimum balance of 5000 TNT at that address
* provide public network services
* pass audits and health checks from Chainpoint Core

__*Chainpoint Nodes that don't meet all these requirements consistently won't be eligible to earn TNT through periodic rewards.*__

### What does a Node do?

Chainpoint Nodes aggregate incoming hashes into a Merkle tree every second. The Merkle root is submitted to Chainpoint Core for anchoring to public blockchains.

Nodes allow clients to retrieve proofs for hashes that were previously submitted.

Nodes maintain a public mirror of the Calendar. This allows *any* Node to verify *any* proof.

Nodes expose a public HTTP API. There is some additional documentation, and examples of using the Node's public HTTP API with `curl` or other clients that can be found on the Wiki:

[Node HTTP API](https://github.com/chainpoint/chainpoint-node/wiki/Node-HTTP-API)

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

When started, `docker-compose` will install and run several system components in the Docker virtual machine.

* Chainpoint Node (a Node.js API server + RocksDB)
* PostgreSQL DB
* NTP Time server (only if NTP is not already running natively)

These applications are started as a group and should not interfere with any other software systems running on your server. We do recommend running a Node on a server dedicated to that task.

Each Node instance you want to run will need to be configured with:

* A dedicated Ethereum address
* Public IP address (ports `22` and `80` open)
* Minimum TNT balance

### System Requirements

The software should be able to be run on any system that supports the Docker and Docker Compose container management tools and meets the minimal hardware requirements.

#### Hardware

The optimal hardware requirements for running a Node are relatively modest.

Pro (High Volume):

- `>= 8GB RAM`
- `4 CPU Core`
- `>= 2GB swapfile`
- `64GB+ SSD`
- `Public IPv4 address`

Recommended (Avoids most RAM issues):

- `>= 2GB RAM`
- `2 CPU Core`
- `>= 2GB swapfile`
- `40GB+ SSD`
- `Public IPv4 address`

Bare Minimum (May encounter RAM issues, depending on host setup):

- `1GB RAM`
- `1 CPU Core`
- `>= 2GB swapfile`
- `25GB+ SSD`
- `Public IPv4 address`

Running a Node on a server with 1GB of RAM has been [known to cause issues](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions#operating-and-monitoring-a-node).

Nodes have relatively modest requirements for RAM and CPU. Nodes that receive sustained high volumes of hashes will write some temporary "proof state" data to SSD (approximately 350MB per million hashes). It is recommended to provision a minimum of 25GB of SSD storage. This temporary data will be automatically pruned over time.

RocksDB, used internally for data storage, is optimized for SSD disks. It is recommended to use SSD disks instead of traditional hard disks whenever possible.

If large volumes of hashes are sent to your server it's recommended that you scale-up the system by adding more RAM and SSD disk storage. Alternatively, you can scale-out horizontally by running more Nodes.

It is not supported to run multiple instances of the Node software on a single physical host.

#### Operating System

The software has been tested and is supported on the following operating systems:

* `Ubuntu 16.04 LTS`
* `macOS Version 10.12.6+`

It will likely run on other operating systems that support Docker and Docker Compose, but support is not currently provided for those.

#### Docker & Docker Compose

Nodes have been developed and tested on the following software versions.

* `Docker version 18.05.0-ce, build f150324`
* `docker-compose version 1.21.2, build a133471`

## Installation

This software is designed to be simple to install and run
on supported systems. Please follow the instructions below
to get started.

The following instructions should run on any public host running the `Ubuntu 16.04 LTS` operating system.

### Prerequisites

Before you start, you will need:

* An Ethereum address that you have the private keys for. Exchange provided accounts are generally not supported. You should be able to unlock your account to send Ether or TNT using MyEtherWallet for example.

* You must have the mimimum balance of 5000 TNT to run a Node, and those TNT must be assigned to the Ethereum address you'll use to identify your Node. You can check your TNT balance (in Grains, divide by `100000000` (10^8) for TNT balance) using the Etherscan.io [contract reading tool for our ERC20 smart contract](https://etherscan.io/address/0x08f5a9235b08173b7569f83645d2c7fb55e8ccd8#readContract) (input your address in the `balanceOf` field and click `Query`).

If you run into any issues operating your Node, the first best place to look for help is the [Frequently Asked Questions](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions) page on our Wiki.

### Start a Server

Your first step is to start a server and gain SSH access
to your account on that server. This is beyond the scope of this document. You will need:

* `root` access, or a user with `sudo` priveleges
* Ubuntu 16.04 LTS OS

You should always choose the simplest Ubuntu 16.04 image provided by your hosting provider. "Desktop" versions, or those that run an enabled version of the `ufw` firewall by default are not recommended as there are known compatibility issues with Docker and system firewalls. 

Log in to your server via SSH and continue to the next step, installing Docker and `docker-compose`.

### Install Docker and Docker Compose

To make this process easy we have created a small script, designed to be run on `Ubuntu 16.04 LTS`, that will install all runtime dependencies with a simple one-line command:

```sh
curl -sSL https://chainpoint-node.storage.googleapis.com/setup.sh | bash
```

Since this command runs a shell script as a priviledged user on your system we recommend you [examine it carefully](https://github.com/chainpoint/chainpoint-node/blob/master/scripts/setup.sh) before you run it.

Simply copy/paste the command into your terminal, logged in as the root user, or another that has sudo privileges, and it will:

* Install Docker
* Install Docker Compose
* Configure a 2GB swap file that will survive reboots
* Adjust system config related to swap performance
* Grant the ability for your local user to run Docker commands without using `sudo`
* Download this repository to your home folder
* Create a default `.env` environment file, ready for you to edit

**Important**: You should close your terminal SSH session and login again after running it to make sure that the changes in the script are fully applied. You do not need to reboot your server.

#### Manual Install

If you prefer to do things manually there are [good instructions available](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04) for installing Docker on an Ubuntu server.

There are also [official docs for installing Docker](https://docs.docker.com/engine/installation/) on other systems.

For some systems you will need to separately install `docker-compose`.

### Sync your System Clock with NTP

Linux servers use a system service known as the Network Time Protocol (NTP) for synchronizing themselves to extremely accurate time sources. It is quite easy to setup a server so that it will stay within milliseconds, or even microseconds, of international standard clocks.

For Chainpoint Nodes we recommend using the public NTP time servers provided by Google. This will ensure that your servers are as close to Chainpoint Core server time as possible. Your Node will be continuously audited to ensure that it is within tolerances (currently max 5 seconds). Please take a moment to setup NTP to ensure you stay eligible for rewards over time.

* [Google Public NTP](https://developers.google.com/time/)
* [How to Configure NTP for Use in the NTP Pool Project on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-configure-ntp-for-use-in-the-ntp-pool-project-on-ubuntu-16-04)

If your system is not running its own NTP daemon (many do so by default), a priviledged Docker container will attempt to start and continuously sync time for the Node.

### Configure Your Node

Configuration is as simple as editing a single configuration file and providing two variables. We provide a sample configuration file in this repository called `.env.sample`.

The installation script, if you use it, will copy that file
to `~/chainpoint-node/.env` for you, ready to edit.

If you installed everything manually you will want to:

```sh
cd ~/chainpoint-node
cp .env.sample .env

# use your favorite editor:
vi .env
```

There are only two values that you may need to edit (comments removed for clarity):

```sh
NODE_TNT_ADDRESS=
CHAINPOINT_NODE_PUBLIC_URI=
```

`NODE_TNT_ADDRESS` : should be set to your Ethereum address that contains TNT balance. It will start with `0x` and have an additional 40 hex characters (`0-9, a-f, A-F`). This is the unique identifier for your Node.

`CHAINPOINT_NODE_PUBLIC_URI` : should be a URI where your Node can be publicly discovered and utilized by others. This might look like `http://10.1.1.20`. Your Node will run on port `80` over `http`. If provided, this address will be periodically audited by Chainpoint Core to ensure compliance with the rules for a healthy Node. If you leave this config value blank, it will be assumed that your Node is not publicly available, and you will not be eligible to earn TNT rewards.

Once running you should be able to visit `http://YOURIP/config` from another host on the Internet and see a JSON response.

### Node Firewall

The network security of a Node is solely the Node operator's responsibility. We do not manage or modify the security settings or firewall of your Node server.

Most hosting providers block all incoming traffic (other than SSH on port 22) by default. You will need to expose port 80 (HTTP) to the world if you want your Node to be available for
clients to connect to. This is true whether you run a non-public host behind a firewall
or a public host. If your provider
does not implement a block by default policy you are encouraged to either choose another provider
or configure a firewall on your Node server to block access to all ports with the
exception of port `80 (HTTP)` and port `22 (SSH)`.

### Run Your Node

Now its time to start your Node!

After finishing the configuration in the `.env` file and saving it make sure you are in the `~/chainpoint-node` directory and run `make`. This will show you some Makefile commands that are available to you. Some of the more important ones are:

* `make up` : start all services
* `make down` : stop all services
* `make upgrade` : upgrade to newest release in git, restarting *all* services
* `make restart` : restart only the Node software. DB services and git unaffected.
* `make logs` : show, and tail, the `docker-compose` logfiles
* `make ps` : show the status of the running processes

The simplest step at this point is to run `make up`. This
will automatically pull down the appropriate Docker images
(which may take a few minutes the first time, when there is an upgrade available, or on slower networks) and start them. `docker-compose` will also
try to ensure that these services keep running, even if they were to crash (which is unlikely).

If you log out of your SSH session it will have no effect on your Node as long as you start it as described above.

### Monitor Your Node

There are two primary ways to monitor the health and operation of your Node. An authenticated web console, and via the command line.

#### Node Web UI

Once your Node is running, you can visit the URL `http://<YOUR-NODE-IP-ADDRESS>` in a browser. This UI is not public by default and you will be prompted to authenticate. The default password for your Node UI is the same as the `NODE_TNT_ADDRESS` that you set in your `.env` config file.

The Node UI will provide you with information related to the current activity of your Node, as well as statistics provided by Core about the health of your Node as measured during the twice hourly audit process and information about the count of the active Nodes in the queue. The 'Activity' page data is updated every few seconds, and the Node health information on the 'About' page is updated twice hourly. Health data is considered private to the Node and is pushed to the Node as a cryptographically signed data packet. There is no public API that similar information can be retrieved from.

If you prefer to set your own password for your Node UI there are instructions provided in the `.env.sample` file.

#### Command Line

In a terminal SSH session run `make ps` to see the `docker` services that are running.

Run `make logs` to continuously tail the logfiles for all `docker-compose` managed services.

When you start your Node you'll see in the logs that your Node will attempt to register itself with one of our Chainpoint Core clusters and will be provided with a secret key.

The Node will then go through a process of downloading, and cryptographically verifying the entire Chainpoint Calendar. Every block will have its signature checked and will be stored locally. This process may take some time on first run as our Calendar grows. After initial sync, all incremental changes will also be pulled down to every Node, verified and stored.

If there are any problems you see in the logs, or if something is not working as expected, please [file a bug](https://github.com/chainpoint/chainpoint-node/issues) and provide as much information about the issue as possible.

### Transferring TNT for Credits

Update 9/19/2017

Nodes will receive enough credits to submit the maximum number of hashes to Core per day. This credit model will remain active until further notice. At this time, there is no need to convert TNT to credits.

### Sending Hashes to Your Node with the CLI

Now you should be fully up and running! You might want to try out your new Node with the [Chainpoint Command Line Interface (CLI)](https://github.com/chainpoint/chainpoint-cli).

Normally the CLI will auto-discover a Node to send hashes to. Once you have it installed, you can configure it to always use your Node if you prefer.

You can either modify the Node address in the `~/.chainpoint/cli.config` to set it permanently, or you can override the Node address every time you use it like this:

```sh
chp submit --server http://127.0.0.1 <hash>
```

### Stopping Your Node

You can stop your Node at any time with `make down`. You can
verify that everything is stopped with `make ps`.

### Node Authentication Key Backup/Restore

*tl;dr* : On-server backups are now performed automatically (`v1.5.3+`). Export your auth keys with `make print-auth-keys` and store those backups elsewhere!!!

This command will print the `HMAC` keys to the console `STDOUT` and also give you a handy one-liner `echo` command to help with restoring the auth key on another host.

The following info may be useful if at some point in the future you need to backup/restore a Node or run it on a new host server.

### About Authentication Keys

Once your Node starts and registers itself with Chainpoint Core a secret key, sometimes referred to
as an `HMAC` or `Auth` key, will be generated and shared with your Node. This key sharing will only ever
take place once, at the moment when you first register your Node. The key will be stored in your Node's
local database. Every time that your Node starts it will use this key to authenticate itself to
Chainpoint Core and update your registered public IP address as needed. The Node's database can store
multiple auth keys and will choose the matching one based on the Ethereum address you've configured
in the `NODE_TNT_ADDRESS` environment variable in your Node's `.env` file.

*WARNING* : If this secret key is lost:

* you cannot recover it by any other means
* there is no way to "reset" the auth key associated with your Ethereum (TNT) address
* you will never be able to start another Node using the same Ethereum address.

To avoid loss you will want to back it up and store it somewhere safe in case of accidental deletion.

#### Backup

As of v1.5.3+ Nodes will automatically perform backups when the Node registers with Core and upon each startup. This will create a backup file for every auth key in your database in
the `keys/backups` sub-directory of your Node. The filename of the backup is composed of
the combination of your ETH address and the current time in the form: `<ETH_ADDRESS>-<TIMESTAMP>.key`.
The contents of the file will be a single line of text which is the HMAC Auth key associated
with that address.

The `make backup-auth-keys` is no longer needed and will be removed in the future. You are still responsible for copying these backups to a safe place though!

#### Restore

Restoration of a backup copy of an auth key is easy. Every time a Node starts it looks at the
contents of the `~/chainpoint-node/keys` directory. If it finds a file where the name has one
of the following two patterns it will read the auth key out of the file and automatically import it into your Node.

* `<ETH_ADDRESS>.key`
* `<ETH_ADDRESS>-<TIMESTAMP>.key`

The contents of the `.key` file is simply the HMAC auth key for the address on a single line.

A `.key` file can be created using the backup procedure above, or you can manually create it.
If you manually create it, you don't need to include a timestamp in the filename.

__Restore Manually Created File__

Create a backup file (e.g. by copying the output of `make print-auth-keys` to a password manager). Restart your node with `make restart` after you do this to import the new auth key. The `make print-auth-keys` command will now also print an echo statement that can be used like this to help restore a key:

```sh
# an example of creating a key backup file manually
# run this in your `chainpoint-node` dir.
echo -n "my-secret-auth-hmac-key" > keys/0xMYETHADDRESS.key
```

__Restore Previously Backed Up File__

You'll find backup files in the `~/chainpoint-node/keys/backups` directory.

Copy the backup file where the filename matches the `NODE_TNT_ADDRESS` you have configured in your `.env` file from the `~/chainpoint-node/keys/backups` directory to the `~/chainpoint-node/keys` directory in order to make it ready to import when the Node next restarts.

Restart your node with `make restart` after you place a `.key` file in the `keys/` dir.

__Verify A Restoration__

When your Node restarts, if it found a `.key` file in the `~/chainpoint-node/keys` directory it will try to restore the auth key in that file to your local database. If it succeeds you will see a line similar to the following in your `make logs` output:

```sh
INFO : Registration : Auth key saved to local storage : 0x<MYETHADDRESS>-<TIMESTAMP>.key
```

## Frequently Asked Questions

Answers to many questions that have been raised by Node operators, and helpful tips, can be found in our [FAQ](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions#operating-and-monitoring-a-node)

Please refer to this document before filing any issues.

## License

[Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0)

```text
Copyright (C) 2017-2018 Tierion

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Thank You!

Thank you for being an active participant in the Chainpoint Network and for your interest in running a Chainpoint Node. We couldn't do it without you!



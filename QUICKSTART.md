# Chainpoint Node Quickstart

This Chainpoint Node was created from a pre-built image and includes all software needed to run a Node as well as some some additional helpful software. No further software installation steps are needed, only some small configuration changes.

## Setup and Run

All of the following setup and run commands are performed from within the `chainpoint-node` directory. Start by changing to that directory.

Example:

```
cd /home/ubuntu/chainpoint-node
```

### Initial Setup

In preparation for running a Node you must modify the `.env` file to configure the Node to register with the Ethereum address that is assigned the appropriate amount of TNT tokens as "stake" as well as the public IP address of the Node. Once you've setup your Ethereum wallet you should modify the `.env` file as documented within the file itself. If you ever need to restore that file to its original state there is a copy to be found in `.env.sample`.

### Running a Node

The Node is controlled by running commands defined in a `Makefile`. You can view the available commands by running `make` or `make help`. These `make ...` commands can only be run from within the `chainpoint-node` directory.

There are only a few common commands that you need to become familiar with to operate a Node.

The first commands to learn are `make up`, `make down`, and `make restart` which will start, stop, or restart a Node. Once you start a Node with `make up` it should keep running on its own until you stop it, or until the server is rebooted or shutdown. It's OK to exit your SSH login session and come back later, it won't affect your Node.

Next is `make logs`, which will display a running list of all of the logfile output from your Node. These logs contain some important information about the Node's operation and health. When you run `make logs` it will keep streaming the output to your screen as it is generated. If you want to exit the log output press the `control-c` key combination.

Lastly, is `make upgrade`. When a new Node release comes out you can run this command to pull down the latest software and restart your Node with the new version. You can run this command at any time, but it is suggested to follow our social media channels for the latest info on new releases:

* Github [chainpoint/chainpoint-node](https://github.com/chainpoint/chainpoint-node)
* Twitter [@tierion](https://twitter.com/tierion)
* Medium [medium.com/tierion](https://medium.com/tierion)

Additional documentation about managing a Node can be found in the [README](https://github.com/chainpoint/chainpoint-node/blob/master/README.md). Frequently Asked Questions are answered in our [FAQ](https://github.com/chainpoint/chainpoint-node/wiki/Frequently-Asked-Questions).

## Thank You

Thanks for your interest in running a Chainpoint Node.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.5.2] - 2018-07-30

### Changes

- Write ephemeral proof state to RocksDB (formerly Redis). This provides a significant increase in sustained inbound hash rate while consuming disk space instead of RAM. The ephemeral data written to RocksDB is auto-pruned after 24 hours. The Redis database will be removed from the Node in a future release.
- Upgrade to PostgreSQL 9.6.9
- Upgrade to Redis 4.0.10
- Upgrade Node.js (`node:8.9.0-alpine` -> `node:8.11.3-stretch`) Docker container base
- Reduce HTTP calls to `PUT /nodes` if request body matches previous successful `PUT`.
- Certain caching functions, which contain small amounts of volatile data, now store their data in RAM instead of Redis.

### Added

- Improved handling of processing time hints from Chainpoint Core.
- Auto-migrate old Redis proof state and other Redis data to RocksDB on initial startup.

### Fixed

- Node UI React application internal re-factoring and bugfixes.
- Ensure `validator.isIP()` receives a string avoiding rare crash in `1.5.1` release.
- Re-create `/keys/backups` directories if previously deleted.
- Improve detection, handling, and UI messaging in Brave browser when third-party cookies and local storage are disabled.
- Trim whitespace from the list of hashes provided to `POST /hashes` using the `hashids` request header.
- Further enforce Node operation on HTTP port 80.

## [1.5.1] - 2018-07-03

### Changes

- Replaced Node local firewall with custom updatable IP filter. This eliminates the need for the Node to schedule and perform automatic restarts.
- If a Node receives an HTTP `426 Upgrade Required` error from Core, indicating that the Node is running too old a version of the Node software to update its registration, it will no longer retry a request that cannot succeed. It will log an error message to the logs and exit.
- During registration, if an HTTP `409 Conflict` error is thrown as a result of the Ethereum address or public URI already being registered, the Node will no longer retry and will exit.
- When a Node is configured password with `CHAINPOINT_NODE_UI_PASSWORD=false` the Node UI will bypass the login screen and redirect the user directly to dashboard.

### Fixed

- An issue with persisting Redux data to browser local storage which sometimes resulted in the Node UI appearing 'stuck' and not displaying the most current data.
- Enabled authentication form submit via [enter] key, only validate after form submitted.

## [1.5.0] - 2018-06-27

### Changes

- Reduce retry count for failed registrations to 3.
- Nodes that fail to register will no longer exit after retries. The Node will continue to run, allowing access to the Node UI.
- Allow adjustment of Node hash aggregation period based on Core config.
- Update Chainpoint library dependencies `merkle-tools` and `chainpoint-parse` to current versions.

### Added

- New Makefile target for `make print-auth-keys` which will print the filename and auth key contents of each file in the `keys/backups` directory. This allows for easier copy/paste of backup key contents as an alternative to exploring the files in the `keys/backups` directory.
- Auth keys will be automatically backed up to the local drive on registration.
- Log some additional details about the cause(s) of a failed audit to the `make logs` output.

### Fixed

- Specifying `false` as a Boolean or String to `CHAINPOINT_NODE_UI_PASSWORD` in `.env` configuration will now work as expected.
- Update to Node UI to correctly display Node ms delta.
- Simplify and enhance performance of Core proof retrieval.

## [1.4.2] - 2018-05-08

### Changed

- `make clear-containers` will now only apply to Chainpoint related containers.
- `make clear-containers` no longer uses `sudo`. Assumes you have setup system so that logged-in user has permissions to docker commands without use of `sudo`.
- The check for Ubuntu OS in certain `make` commands will no longer exit make task if Ubuntu not detected. A warning will be printed on `make up` and `make upgrade` if not running Ubuntu.
- Log an error if `CHAINPOINT_NODE_PUBLIC_URI` is set to an RFC-1918 private IP address that will never be routable over the public Internet.

### Fixed

- Restoration of auth keys from a `.key` file where the file contains trailing newlines or whitespace now works as expected.
- A spurious error related to importing a backup auth key : `INFO : Registration : HMAC Auth Key Not Found`
- Importing an auth key backup where there is whitespace in the `.key` file.
- The `make upgrade-docker-compose` task caused issues for some as apparently the binary download from its source Github repository is unreliable and can cause an upgrade to a corrupted binary. We are now providing a download of our own binary for `docker-compose` which is frozen into this repository as well. You can install it using `make upgrade-docker-compose` or, if your `docker-compose` install is already having issues and you can't do a normal `make upgrade`, you can use the out-of-band installation by running the following `curl` command. This will download the same frozen Linux binary. This should resolve issues with `text file busy` errors and allow you to proceed normally with `make upgrade`.

```curl
curl -sSL https://chainpoint-node.storage.googleapis.com/docker-compose-install.sh | bash
```

## [1.4.1] - 2018-05-04

### Changed

- Enhanced backup and restore documentation in the README.md file

### Added

- If a `CHAINPOINT_NODE_PUBLIC_URI` is provided (public Node) the Node will perform an HTTP health check on startup to ensure that the configured URI is the same as the Node is actually running on. Will help prevent IP misconfiguration and resulting audit failures. The Node will exit if mis-configured and can't reach itself on the IP URI configured.
- A newly registered Node will now automatically generate a backup of the Node Auth key without user intervention. This will only be triggered on first Node registration, and not on subsequent updates.
- A new Makefile task `make upgrade-docker-compose` which will upgrade it to version `1.21.0`. This task will now be run automatically on `make upgrade` as well.
- A new Makefile task `make clear-containers` which will stop and remove any running Docker containers on the host. This will be run automatically on `make up` and `make upgrade` as well. This prevents occasional issues with stuck containers that would cause an error on Node upgrade.

### Fixed

- Node UI login on Microsoft Windows 10 - Edge browser v16 & v14 - now works.
- Restoration of auth keys from a `.key` file where the Ethereum address in the filename is mixed case now works as expected.

## [1.4.0] - 2018-05-03

### Added

- Node UI (preview version) and secure transfer of audit health data to Node
- Local caching of Core proofs
- Make use of new `COMPOSE_IGNORE_ORPHANS` env var with `docker-compose` to hide unneeded 'orphan container' warnings. Requires current version of `docker-compose` which can now be upgraded in place using `make upgrade-docker-compose`

### Changed

- Updated Docker ntpd image
- New auth key backup/restore method `make backup-auth-keys` which will store backups as files in `keys/backups` directory, and allow restore from `keys` directory
- Upgraded Redis docker image to v4.0.9
- Upgraded NTPD docker image
- `.env.sample` updated to document new Node UI password configuration
- `make upgrade` will now ensure that the Node is being upgraded from the `master` branch of the Github repository
- Prevent the Node daily auto-restart from occuring near the time of scheduled audits

### Deprecated

- `make auth-keys` will be removed in a future release. It is now an alias for the new `make backup-auth-keys`

## [1.3.7] - 2018-04-03

## [1.3.6v] - 2018-02-27

## [1.3.6] - 2018-02-26

## [1.3.5] - 2018-01-24

## [1.3.4] - 2018-01-05

## [1.3.3] - 2017-12-12

## [1.3.2] - 2017-12-01

## [1.3.1] - 2017-11-28

## [1.3.0-b] - 2017-11-20

## [1.3.0-a] - 2017-11-20

## [1.3.0] - 2017-11-19

## [20171019-eof] - 2017-10-19

## [20171019-readme] - 2017-10-19

## [1.2.1a] - 2017-10-18

## [1.2.1] - 2017-10-18

## [1.2.0] - 2017-10-13

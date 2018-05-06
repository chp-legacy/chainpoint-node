# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- `make clear-containers` will now only apply to Chainpoint related containers.
- `make clear-containers` no longer uses `sudo`. Assumes you have setup system so that logged-in user has permissions to docker commands without use of `sudo`.
- The check for Ubuntu OS in certain `make` commands will no longer exit make task if Ubuntu not detected. A warning will be printed on `make up` and `make upgrade` if not running Ubuntu.

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
- Restoration of auth keys from a `.key` file where the file contains trailing newlines or whitespace now works as expected.

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

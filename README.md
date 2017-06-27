# Docker-based Everquest Emulator

## Introduction

DockerEQ uses docker-compose to orchestrate and manage the links between each container to run an [Everquest Emulator](http://www.eqemulator.org/) server.

### Requirements
* [Docker](http://docker.com)
* [Docker Compose](https://github.com/docker/compose/releases)

### What Does This Do?
DockerEQ builds out an everquest development environment by using 4 different containers:
1) buildeq - Compiles code and maintains a dev environment, keeping it off the production-ready container.
2) eqemu - Represents a production environment, using supervisord to spin up world and zone.
3) mariadb - Contains a SQL database. This is kept independent in case your live environment uses a cloud-replicated storage engine.
4) web - Handles web related tools and services, kept indepenedent in case web hosting is seperated.

### Monitoring
* Once started, use http://127.0.0.1:9001 to monitor processes ran by supervisord.

### Installation
* run `./install.sh`
* A prompt appears asking what repositories to pull source code, quest files, maps, and database information from. By default, this uses the eqemu/master branch, and some local snapshots maintained by xackery (eqquests, eqmaps, eqdb). Change as appropiate.
* Edit your eqhost.txt to connect to the proper server

### Environment Rundown
* An env.txt file is created in the root directory of the repository to set these variables for future runs.
* /eqemu/ is created as a basepoint for all source code. The binaries are built out to the /eqemu/bin/ folder.
* Inside the /eqemu/bin/ folder, quests, maps, and db folders are created and versioned based on the git pull.
* /db/ is created to store local database changes.


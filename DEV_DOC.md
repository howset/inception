# DEV_DOC.md
This document is aimed to be a non-comprehensive description of seting up, building, launching, and managing docker-based infrastructure for this Inception project.

## Setting up the environment
Requirements:
- Linux virtual machine
- Docker and docker-compose installed in the virtual machine
- Git and make
- Cloned content of the repository
- Secret files that are not included in the content of the repository but can be manually created in a specific location (`secrets/[secret file]`).

Cofiguration:
- Other than the secret files that can be freely modified, some configurations (e.g. names, ports, etc) can also be set by editing the `srcs/.env` file.
- Going directly to the docker-compose.yml file, many adjustments can be made. The commands used for healthchecks are chosen arbitrarily and in principle can be anything, as well as the time (intervals/timeouts/retries). 

## Building and launching
- Build and start the whole project by `make bonus` or just `make all` to exclude the bonus. This runs `docker-compose build` then `docker-compose up -d` and also creates directories for the bind mounts for the volumes as required.
- Other utilities
	```sh
	#stop and remove containers (and network)
	$> make down

	#stop running containers (without removing)
	$> make stop

	#start stopped containers
	$> make start

	#remove images as well
	$> make clean

	#remove everything (incl. bind mounts & clean-up cache)
	$> make fclean
	```
- During launching, it may take sometime for the services to start especially for the essential mandatory parts. This is due to the healthchecks and dependencies as specified in the `srcs/docker-compose.yml` file. If this is not wished, the corresponding parts can be commented out though this may require some more troubleshooting should some errors arise.

## Management
- `make list` gives an overview of the containers, images, volumes, and network involved in the project. More detailed investigation can be done by `docker inspect [object name]`.
- `make logs` gives the logs of __all__ created containers. For individual containers, use `docker logs [container name]`. This functionality can and should be used extensively to debug any errors.
- Other useful commands
	```sh
	#execute a command in a docker container
	$> docker exec [container name] [command and arguments/options]

	#access a container using sh (alpine has no bash)
	$> docker exec -it [container name] sh
	```
- All required secret files (not included in the repository, but can be manually created) can be found in the `srcs/.env` file and must be put in the `secrets/` directory (create it if necessary).
- Location of the bind mounts for data are hardcoded in the `srcs/docker-compose.yml` file. This can be changed manually as well.

## Data storing and persistence
- That brings us to the storage, the location of which has been mentioned.
- The storage (volume) is not managed by docker but rather bind mounts to a location in the (VM's) storage. Therefore, stopping and removing the conatiners (and images) wihtout touching the volume would maintain the persistence of the changes that was made. 

## Notes
- The bonus adds links on the homepage to some of them to provide convenience, this is handled directly by the makefile. Without this, those services can still be accessible by writing the absolute path in the url bar of the browser.
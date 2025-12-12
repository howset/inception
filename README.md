_This project has been created as part of the 42 curriculum by hsetyamu_

# README.md
## Description
This is a containerization project to learn modern infrastructure concepts using docker and docker-compose.
The goal is to build and deploy a modular and isolated system while maintaining the principles of service isolation, networking, automation, and persistence.

The project creates and orchestrates several docker containers, namely nginx, wordpress, and mariadb, each running in its own containers, communicating only through docker networks, and persisting data with bind mounts. The setup is automated through the use of a makefile and docker-compose, ensuring that the whole infrastructure can be built, started, and cleaned conveniently.

To ensure robustness, healthchecks and dependencies are applied. The aim is to make sure that services that relies on the well-being of other services starts after that service is healthy.

### Virtual Machines vs Docker
The use of virtual machine provides many advantages in respect to guarantee control and compatibility as well as provide a safe sandbox environment.
Although a docker container in principle offers the same advantages, the underlying principles of how they work differs.

A virtual machine basically emulates an entire computer system along with all the necessary components: kernels, resources, os, etc. A docker container does not do that, but instead rely on an existing kernel.
This leads to differences on other levels as well, such as the use of resources among others. 

### Secrets vs Environment Variables
Variable configurations (e.g. ports, names) for the project can be passed either as environment variables or as secrets. 

Using environment variables is a convenient way to define configurations that can be accessed by docker-compose. However it is rather insecure due to the fact that this can be inspected in the metadata of an image/container. As such, sensitive variables/essential credentials (namely passwords) should be guarded in a different manner. Secret files, when properly managed, avoid this pitfall. And whenever necessary, additional steps can be taken to further secure the information contained in the secret files.

What should be considered as sensitive or not can be different in different context.

### Docker Network vs Host Network
Docker network provides security through isolation and allows multiple containers to use the same ports without conflicts (through port mapping), and enable connections using container names. Host networking offers better performance and simpler configuration but exposes containers directly to the host's network, which can be a security concern in production environments.

### Docker Volumes vs Bind Mounts
Persisting data can be done in either ways. Docker volume stores data in a fixed location in the host. The management, set-up, and permissions are handled by docker. Bind mounts however allows the data storage to be defined explicitly anywhere in the host. There is really no obvious disadvantage of using docker volumes compared to bind mounts other than the fact that bind mounts provides more transparency.

## Instructions
### Requirements
- __virtual machine__ Linux based
- __docker__ and __docker-compose__
- __make__  and __git__
- __port 443__ available on the host machine

### Installation & Setup
1. __Clone the repo__
2. __Configure environment variables:__

	Open `srcs/.env` and make changes if necessary:
	```sh
	#domain name
	DOMAIN_NAME=[name].42.fr

	#db configs
	...
	DB_PORT=3306
	...

	#secrets location for passwords and username
	DB_USER_PW=[secret file location]
	DB_ROOT_PW=[secret file location]
	...
	```
3. __Create secret files:__
	
	Create `srcs/secrets/` and add the passwords:
	```sh
	$> mkdir -p srcs/secrets
	$> echo "[whatever db user password]" > secretsc/db_user_pw
	$> echo "[whatever db admin password]" > secrets/wp_adm_pw
	...
	```
4. __Configure hosts file (on VM):__

	Edit directly or add the domain to `/etc/hosts`:
	```sh
	$> sudo echo "127.0.0.1	[name].42.fr" >> /etc/hosts
	$> sudo echo "127.0.0.1	adminer.localhost adminer.[name].42.fr" >> /etc/hosts #bonus
	$> sudo echo "127.0.0.1	portainer.portainer adminer.[name].42.fr" >> /etc/hosts #bonus
	```
5. __Other configurations__

	Obviously, the `srcs/docker_compose.yml` and each services' dockerfile can be directly edited as necessary.
	Along that line, might as well edit the scripts and config files for each service if one is so inclined. Feel free.

### Compilation & Execution
#### Build and Start All Services
```sh
#From the root dir
$> make

#Or for bonus
$> make bonus
```
This will:
- Create necessary data directories
- Build all Docker images from Dockerfiles
- Start corresponding containers (mandatory/bonus)
- Perform healthchecks and start the next containers following the specified dependencies
- Set up networks and volumes

#### Inspections
```sh
#Log of all services
$> make logs

#Status of images, containers, volumes, and network
$> make list

#Log of a specific service
$> docker logs [container name]

#Inspect metadata of a specific object
$> docker inspect [object name]

#Check docker disk usage
$> docker system df

#Check top level process in running containers
$> docker top
```

### Accessing Services
Once running, access the following services:
1. [mandatory] __wordpress__ using __mariadb__ through __nginx__ : `https://[name].42.fr`
2. [bonus] __static page__ : `https://[name].42.fr/jumper`
3. [bonus] __adminer__ : `https://adminer.[name].42.fr`
4. [bonus] __redis__: login to `https://[name].42.fr/wp-admin` and check the plugin status
5. [bonus] __ftp__: use an ftp client (lftp/filezilla) and connect to `ftp://[name].42.fr` port 21
6. [bonus] __portainer__ : `https://portainer.[name].42.fr`

__Note:__ accept the self-signed SSL certificate in browser.

### Stopping & Cleaning
```sh
#Stop all running containers (can be rerun by make up, data is untouched)
$> make down

#Stop and remove containers and images (must make again, data is untouched)
$> make clean

#Complete cleanup (removes everything including data and cache)
$> make fclean
```

### Useful Commands
```sh
#Enter a container shell
$> docker exec -it [container name] sh

#Run command without entering the shell
$> docker exec [container name] [command and arguments/options]
```

### Troubleshooting
__dependency errors__
- Just comment out the dependencies line(s) in the docker-compose.yml file or `up` with the `--no-deps` flag
- Adjust the healthchecks (change the command or timeouts/intervals)

__container won't start:__
- Check logs: `docker logs [container name]`
- Verify secrets exist in `secrets/`

__cannot access services:__
- Verify containers are running: `make list`
- Ensure domain is in `/etc/hosts`

__permission denied errors:__
- Ensure user is in `docker` group: `sudo adduser [name] docker`
- Reboot after adding to docker group

__database connection errors:__
- Verify mariadb container is healthy: `make list` and/or `docker logs [mariadb container name]`
- Check credentials in secrets and .env
- Ensure wordpress can reach mariadb: `docker exec [wordpress container name] ping mariadb`

## Resources
- The following are resources that was used as starting points. The whole project requires a lot more of these than what one can easily keep track.
	- https://wiki.alpinelinux.org/wiki/MariaDB
	- https://wiki.alpinelinux.org/wiki/Nginx
	- https://wiki.alpinelinux.org/wiki/WordPress
	- https://wiki.archlinux.org/title/Nginx
	- https://wiki.archlinux.org/title/Wordpress
	- https://wiki.archlinux.org/title/MariaDB
	- https://hub.docker.com/_/nginx
	- https://hub.docker.com/_/mariadb
	- https://hub.docker.com/_/wordpress
	- https://make.wordpress.org/cli/handbook/how-to/how-to-install/

- To keep the spirit of clarity, the use of large language models in this project is quite extensive. The challenge posed by having to make components that the project's author have zero knowledge about to work together as a functioning infrastructure is the main reason for this.
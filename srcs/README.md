_This project has been created as part of the 42 curriculum by hsetyamu_

# README.md

## Description
This is a containerization project to learn modern infrastructure concepts using docker and docker-compose.
The goal is to build and deploy a modular and isolated system while maintaining the principles of service isolation, networking, automation, and persistence.

The project creates and orchestrates several docker containers, such as nginx, wordpress, and mariadb, each running in its own containers, communicating only through docker networks, and persisting data with bind mounts. The setup is automated through the use of a Makefile and docker-compose, ensuring that the whole infrastructure can be built, started, and cleaned conveniently.

### Virtual Machines vs Docker
The use of virtual machine provides many advantages in respect to guarantee control and compatibility as well as provide a safe sandbox environment.
Although a docker container in principle offers the same advantages, the underlying principles of how they work differs.

A virtual machine basically emulates an entire computer system along with all the necessary components: kernels, resources, os, etc), a docker container does not do that, but instead rely on an existing kernel.
This leads to differences on other levels as well, such as the use of resources among others. 

### Secrets vs Environment Variables
Variable configurations (e.g. ports, names) for the project can be passed either as environment variables or as secrets. 

Environment variables are a convenient way to define all necessary configuration variables that can be accessed by docker-compose. However it is rather insecure due to the fact that this can be inspected in the metadata of an image/container. As such, sensitive variables/essential credentials (namely passwords) should be wisely guarded in a different manner. Secret files, when properly managed, avoid this pitfall. And whenever necessary, additional steps can be taken to further secure the information contained in the secret files.

What should be considered as sensitive or not can be different in different context.

### Docker Network vs Host Network
Docker networks provide security through isolation and through allow multiple containers to use the same ports without conflicts (through port mapping), and enable connections using container names. Host networking offers slightly better performance and simpler configuration but exposes containers directly to the host's network, which can be a security concern in production environments.

### Docker Volumes vs Bind Mounts

## Instruction


## Resources
- The following are resources that was used as starting points. The whole project requires a lot more of these than what one can easily keep track.
	- https://wiki.alpinelinux.org/wiki/MariaDB
	- https://wiki.alpinelinux.org/wiki/Nginx
	- https://wiki.alpinelinux.org/wiki/WordPress
	- https://hub.docker.com/_/nginx
	- https://hub.docker.com/_/mariadb
	- https://hub.docker.com/_/wordpress

- To keep the spirit of clarity, the use of large language models in this project is quite extensive. The challenge posed by having to make components that the project's author have zero knowledge about to work together as a functioning infrastructure is the main reason for that extensive use.
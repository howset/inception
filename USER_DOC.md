# USER_DOC.md
This document is aimed to be a short overview of the Inception project by hsetyamu for end user (or administrator).

## Services provided by the stack
This project/stack creates multiple docker containers that work together to deploy a wordpress website using nginx and mariadb, along with other services as bonus.

## Starting and stopping the project
- Using the __Makefile__, the mandatory can be built and run (create & start) by `make all`.
- Docker images, containers, networks, and volumes can be inspected by `make list`.
- Should it be necessary, logs can checked by `make logs`. Individual logs of services must be checked separately (`docker logs [container name]`).
- Stopping running containers can be done by `make stop`. If necessary, containers can be removed by `make down`. `make up` run them again. A shortcut to restart (`make down` then `make up`) is `make restart`.
- Clean-up can be done by either `make clean` (does not remove volume directories) or `make fclean` (removes the directory where volumes are stored).
- Bonus can be built and run by `make bonus`.

## Accessing the website & administration
- Access through `http://localhost` or `https://localhost` that will redirect to `https://hsetyamu.42.fr`. 
- Administration can accessed by `https://hsetyamu.42.fr/wp-admin` and supply the necessary credentials (WordPress Admin username & password)
- Some bonus services can be accessed through the same page using the provided links on the page (after bonus is made -- `make bonus`).

## Location and managing credentials
- Inessential credentials are contained in the .env file along with other changeable variables (ports, hostname, etc). 
- Essential credentials (i.e. passwords) must be contained in individual text files, the location of which can be modified by the .env file.

## Checking running services
- The 3 mandatory services can be checked to be running properly by just going to the homepage as mentioned above.
- Persistence can be maintained as long as the data directory (where the volumes are located) is not removed (`make fclean` or manual removal).
-Bonus services:
	- Static page -- Just click the link.
	- Adminer -- Click the link and supply the necessary database credentials.
	- Portainer -- Click the link and just create new admin user
	- Vsftpd -- Relevant package is required (lftp or filezilla) then supply the necessary credentials.
	- Redis -- Login to WordPress admin page, then check the status of the plugin.
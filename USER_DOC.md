# USER_DOC.md
This document is aimed to be a short overview of the Inception project by hsetyamu for end user (or administrator).

## Services
The Inception project deploys a small self-contained infrastructure using `docker` and `docker-compose`.

Core Services:
- nginx -- Accepts external traffic.
- wordpress --  Serves a website with configurable content.
- mariadb -- Serves as a database to store wp data.

Additional Components (Bonus):
- static page -- Provides an example static page.
- adminer -- Provides interface to browse the mariadb database.
- redis -- Plugin that caches wordpress.
- vsftpd -- Provides file transfer capabilities.
- portainer -- Provides interface to browse docker images/containers.

All services are isolated in its containers, communicate through internal docker network, adn persistence is achieved by binding volumes to a specified storage directory.

## Starting and stopping the project
- Using the __Makefile__ at the project root, the mandatory can be built and run (create & start) by `make all`.
- Stopping running containers can be done by `make stop`. If necessary, containers can be removed by `make down`. `make up` run them again. A shortcut to restart (`make down` then `make up`) is `make restart`.
- Clean-up can be done by either `make clean` (does not remove volume directories) or `make fclean` (removes the directory where volumes are stored).
- Bonus can be built and run by `make bonus`.

## Accessing the website & administration
- Access through `http://localhost` or `https://localhost` that will redirect to `https://hsetyamu.42.fr` (obviously, after the services are up and running). 
- Administration can accessed by `https://hsetyamu.42.fr/wp-admin` and supply the necessary credentials (WordPress Admin username & password)
- Some bonus services can be accessed through the same page using the provided links on the page (after bonus is made -- `make bonus`).

## Location and managing credentials
- Inessential credentials are contained in the .env file along with other changeable variables (ports, hostname, etc). 
- Essential credentials (i.e. passwords) must be contained in individual text files (secret file), the location of which can be modified by the .env file. These secret file will not be found in the repository.

## Checking running services
- For an overview of th project, at the project's root, go `make list`.
- Should it be necessary, logs can checked by `make logs`. Individual logs of services must be checked separately (`docker logs [container name]`).
- The 3 mandatory services can be tested to be running properly by just going to the homepage as mentioned above.
- Persistence can be maintained as long as the data directory (where the volumes are located) is not removed (`make fclean` or manual removal).
-Bonus services:
	- Static page -- Just click the link on the page.
	- Adminer -- Click the link and supply the necessary database credentials.
	- Portainer -- Click the link and just create new admin user
	- Vsftpd -- Relevant package is required (lftp or filezilla) then supply the necessary credentials.
	- Redis -- Login to WordPress admin page, then check the status of the plugin.

## Notes
- To reduce complications of having to include too many secret files, generating the self-signed SSL certificate for TLS is done by the nginx container everytime it is run, that means it will always be different. This is __not__ reflective of the reality, but a liberty taken to simplify the approach of the project.
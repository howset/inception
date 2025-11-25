# Inception

## Content
- [Starting points](#starting-points)
- [VM setup & OS installation](#vm-setup--os-installation)
	- [Preparation](#preparation)
	- [Install OS](#install-os)
	- [OS setup, essential installations, & configs](#os-setup-essential-installations--configs)
		- [Getting sudo](#getting-sudo)
		- [Install make, nano & ssh config](#install-make-nano--ssh-config)
		- [Install docker, docker compose, & docker-cli-compose](#install-docker-docker-compose--docker-cli-compose)
		- [Setup a Desktop Environment](#setup-a-desktop-environment)
		- [Setup a shared folder](#setup-a-shared-folder)
		- [Customize the DE](#customize-the-de)
		- [Utilities: VSCode remote SSH, git, etc](#utilities-vscode-remote-ssh-git-etc)
		- [To open the page](#to-open-the-page)
- [Docker containers](#docker-containers)
	- [Mariadb](#mariadb)
		- [Dockerfile](#dockerfile)
		- [Entrypoint script](#entrypoint-script)
		- [Configs](#configs)
	- [Nginx](#nginx)
		- [Dockerfile](#dockerfile-1)
		- [Entrypoint script](#entrypoint-script-1)
		- [Configs](#configs-1)
	- [Wordpress](#wordpress)
		- [Dockerfile](#dockerfile-2)
		- [Entrypoint script](#entrypoint-script-2)
		- [Configs](#configs-2)
	- [Docker Compose](#docker-compose)
		- [Worth mentioning](#worth-mentioning)
	- [Notes](#notes)
- [Evals](#evals)
- [Terminology overload](#terminology-overload)
- [References](#references)

## Starting points
- https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker
- https://wiki.alpinelinux.org/wiki/MariaDB
- https://wiki.alpinelinux.org/wiki/Nginx
- https://wiki.alpinelinux.org/wiki/WordPress
- https://hub.docker.com/_/nginx
- https://hub.docker.com/_/mariadb
- https://hub.docker.com/_/wordpress

## VM setup & OS installation:
Steps that were taken to prepare the VM[^1][^2].

Reqs:
1. Virtualbox
2. Alpine linux
	- Penultimate stable in https://alpinelinux.org/releases/.
	- Go to https://alpinelinux.org/downloads/, find `older releases` @ the bottom of the page.
	- Find the proper version, go to releases (not main), look for -virt & x86_64 for cluster comps (-virt is lts kernel, configured for VM guests[^3])

### Preparation
- Maybe dependent on virtualbox version.
- Open virtualbox & press new.
- Specify folder in `sgoinfre`
- Specify:
	```
	memory 4096MB
	HD 20GB
	processors 4
	```
- Go to settings, storage
- Put the iso in the optical drive (choose other linux 64).

### Install OS
- Press start in virtual box
- __Initial__ login for local hostwith `root`
- Enter `setup-alpine` in the prompt
- __[Keymap]__ Set keyboard layout & variant as `us`
- __[Hostname]__ Enter system hostname as `[username].42.fr`
- __[Interface]__ Just press enter to everything to use the default (`[eth0]` and `[dhcp]`) up to manual network configuration to which answer no (`[n]`).
- __[Root password]__ Setup root password.
- __[Timezone]__ Set proper timezone.
- __[Proxy]__ Set proxy to default (just press enter).
- __[Network Time Protocol]__ Set network time protocol to default as well.
- __[APK Mirror]__ Set apk mirror again to default.
- __[User]__ Setup username (I did [username] all lowercase) & password (I made it the same with root). I did not give full name (just enter). I did not give ssh key, and just defaulted using openssh.
- __[Disk & Install]__ Use `sda` disk as `sys`. Erase and continue (`y`).
- remove the iso from virtualbox & type `$> reboot`. If iso cant be removed, just shutdown (`$> poweroff`) and remove it before restarting.

### OS setup, essential installations, & configs
#### Getting sudo
- Change to root
	```sh
	$> su - #start the shell as login shell
	```
- Make community repo available. Edit the list & uncomment community repo
	```sh
	$> vi /etc/apk/repositories
	```
- Install sudo
	```sh
	$> apk update #Alpine Package Keeper
	$> apk add sudo
	```
- To make it usable, go `visudo`, uncomment `%sudo	ALL=(ALL:ALL) ALL` line.
- Create group & add user (check if sudo group exists: `getent group sudo`, if not then create it)
	```sh
	$> addgroup sudo #create sudo group
	$> adduser [username] sudo #add the username to the group
	$> getent group sudo #recheck
	```
- then reboot (very important!!!)
	```sh
	$> reboot
	```

#### Install make, nano & ssh config
- Make may not be available in minimal distro
	```sh
	$> sudo apk update #just good practice 4 any distro
	$> sudo apk add make
	```
- Install nano for common plebs like me.
	```sh
	$> sudo apk update #just good practice 4 any distro
	$> sudo apk add nano
	```
- Configure ssh.
	```sh
	$> sudo nano /etc/ssh/sshd_config
	```
	- Uncomment `Port 22` then change it to `4242` (like in b2br) & under `Authentication:` uncomment PermitRootLogin then set to no (`PermitRootLogin no`).
	- Similarly,
		```sh
		$> sudo nano /etc/ssh/ssh_config/
		```
	- Uncomment port 22 & change it to 4242.
	- Check ssh service, restart ssh service & recheck (ssh should be 4242).
		```sh
		$> netstat -tul #tool to check netwrok configs
		$> sudo rc-service sshd restart #open-rc is the init system for alpine (like systemd in debians)
		$> netstat -tul
		```
- In virtualbox, go to `settings` -> `network` -> `port forwarding`.
- Set host as 4243 (berlin cluster), guest as 4242. Name it ssh.
- Test from cluster terminal
	```sh
	$> ssh localhost -p 4243 #or ssh 127.0.0.1 -p 4243
	```
- __IMPORTANT!!__ If using git, then better to use host 2222 and guest 22 to avoid conflict with github, so __DON'T__ change the ssh-config & sshd_config!!! (Leave at 22)

#### Install docker, docker compose, & docker-cli-compose
- Get `docker`, `docker-cli-compose`, & `docker compose`
	```sh
	$> sudo apk update #just good practice 4 any distro
	$> sudo apk add docker docker-cli-compose docker-compose
	```
- Update it
	```sh
	$> sudo apk add --update docker openrc
	```
- Configure to start the daemon at boot
	```sh
	$> sudo rc-update add docker boot # or `rc-update add docker default`
	```
- Check status & start if necessary
	```sh
	$> service docker status  # check status
	$> sudo service docker start
	```
- Add user to docker group (necessary to connect to the daemon through the sockets)
	```sh
	$> sudo adduser [username] docker
	```
- Note:
	- `docker`: core Docker runtime (daemon and CLI)
	- `docker-cli-compose`: compose plugin for Docker CLI
	- `docker-compose`: deprecated Python-based Compose binary, included for compatibility reasons only.
- Check docker installation (do this maybe after the VM is established)
	```sh
	$> docker run hello-world
	```

#### Setup a Desktop Environment
- To get a desktop environment[^4].
	```sh
	$> sudo setup-desktop
	```
- Pick xfce like in MXlinux (or whatever is more familiar).
- Simply reboot afterwards.

#### Setup a shared folder
- Create a mount point and install libraries[^5].
	```sh
	$> sudo mkdir -p /mnt/shared
	$> sudo apk add virtualbox-guest-additions linux-virt #install VirtualBox Guest Additions
	```
- Shutdown and setup shared folder in virtualbox gui (`Settings` -> `Shared Folders`).
	```
	- Folder path in host: /home/username/Shared
	- Fodler name: Shared
	- Mount point: /mnt/shared
	- Auto-mount: check
	```
- Start then mount the folder
	```sh
	$> sudo modprobe -a vboxsf #insert module
	$> sudo mount -t vboxsf Shared /mnt/shared
	```
- To make it permanent, add the line `Shared  /mnt/shared  vboxsf  defaults  0  0` in /etc/fstab
	```sh
	$> echo "Shared  /mnt/shared  vboxsf  defaults  0  0" | sudo tee -a /etc/fstab
	or
	$> sudo nano /etc/fstab #then add the line
	```

#### Customize the DE
- Shortcuts:
	- `Applications` -> `Settings` -> `Settings Manager`
		- `Keyboard` -> `Application` shortcut: Change `xfce4-popup-applicationsmenu` to Super btn. Whiskermenu is much better, but must be installed first (`sudo apk add xfce4-whiskermenu-plugin`).
		- `Window Manager` -> `Keyboard`: Adjust window placement (doesnt work :( )
		- `Window Manager` -> `Keyboard`: Adjust moving window to other workspace.
- Get new set of icons, extract, and put in either `/usr/share/icons` or `/home/.local/share/icons`. I chose Zafiro.
	- Choose in `Applications` -> `Settings` -> `Settings Manager`
		- Then `Appearance` -> `Icons`
- Get a dark theme, extract, and put in either `/usr/share/themes` or `/home/.local/share/themes`. I chose Everforest.
	- Choose `Applications` -> `Settings` -> `Settings Manager`
		- Then `Appearance` -> `Style`
		- And `Window Manager` -> `Style`
- Most importantly, change wallpepah! 90% of a theme is the wallpaper.
- If font color for desktop icons has to be changed, edit/add `gtk.css` in `~/.config/gtk-3.0/` with the following:
	<details>
	<summary>🗟Click to expand gtk.css</summary>

	```css
	/* default state */
	XfdesktopIconView.view {
	-XfdesktopIconView-ellipsize-icon-labels: 1;
	-XfdesktopIconView-tooltip-size: 32;
	-XfdesktopIconView-cell-spacing: 4;
	-XfdesktopIconView-cell-padding: 0;
	-XfdesktopIconView-cell-text-width-proportion: 2;
	background: transparent;
	//letters colors
	color: #48494B;
	//radius, letter box corners
	border-radius: 3px; }

	/* active (selected) state */
	XfdesktopIconView.view:active {
	background: rgba(0, 0, 0, 0);
	text-shadow: 0 1px 1px black; }

	/* default label state */
	XfdesktopIconView.view .label {
	background: rgba(0, 0, 0, 0);
	text-shadow: 1px 1px 2px black; }

	/* active (selected) label state */
	XfdesktopIconView.view .label:active {
	color: white;
	background: rgba(0, 0, 0, 0.2);
	text-shadow: 0px 1px 1px black; }
	```

	</details>

#### Utilities: VSCode remote SSH, git, etc
- Edit `/etc/ssh/sshd_config`
- Uncomment/edit/add this lines
	```
	AllowTcpForwarding yes #needed by VSC Remote ssh
	PermitOpen any #just for flexibility
	GatewayPorts no
	```
- Verify, save, and restart SSH
	```sh
	$> sudo rc-service sshd restart
	$> sudo rc-service sshd status
	```
- Install git if necessary (along with the ssh keys if necessary).

#### To open the page
- dont forget to open /etc/hosts and add [username].42.fr to open the page using a browser in the docker host (VM).

## Docker containers
- The base image can basically be from anything, either from debian:bookworm or alpine:3.21.1 as long as the kernel is the same (linux), the difference is the size of the image using alpine ended up smaller than debian (~200 MB vs ~500 MB), and some adjustments also has to be made due to some differences between the systems (e.g. alpine has no bash by default).
- __EXPOSE__ in dockerfiles means nothing other than metadata for documentation. Since this project doesnt really say anything the port to be used for connections between the containers (other than in the diagram, which uses the default ports for the services i.e. mariadb 3306 and php-fpm 9000), so using the defaults would work just fine, namely not defining anything in the dockerfile (See Docker Compose below).
- Useful but can be confusing commands:[^6]
<details>
<summary>🗟Click to expand table of commands</summary>

| Command			| Options	| Parameter			|Function			|
|-------------------|-----------|-------------------|------------------|
| docker ps 		| 			| 					| lists running containers |
| docker ps 		| -a		| 					| lists all containers running or not |
| docker images		| 			| 					| lists all images |
| docker logs 		| 			| [ID]/[Name]		| show logs of a container |
| docker rm 		| 			| [ID]/[Name]		| remove a container |
| docker rmi		| 			| [ID]				| remove an image |
| docker image prune| 			| 					| remove dangling images |
| docker build 		| -t		| [Image_name]	.	| build an image [Image_name]:latest in current dir (.) |
| docker build 		| --no-cache| [Image_name]	[Dir]| build it fresh from [Dir]|
| docker create		| --name	| [Cont_name][Image_name]| create container [Cont_name] from image |
| docker stop 		| 			| [ID]/[Name]		| stop a running container |
| docker start 		| 			| [ID]/[Name]		| start a stopped container |
| docker run 		| 			| [Image_name]		| create and start a container |
| docker run 		| -d		| [ID]/[Name]		| detached |
| docker run 		| --name	| [Cont_name] [Name]| specify name for the container |
| docker run 		| -it		| [Cont_name] bash	| run a container interactive using pseudo-TTY |
| docker run 		| -p 		| <host_port>:<container_port> <image_name> | run container & publish a port to the host|
| docker start 		| 			| [ID]/[Name]		| start a container |
| docker restart	| 			| [ID]/[Name]		| restart a container |
| docker exec 		| -it		| [Cont_name] bash	| execute -it on a running container using bash|
| docker top 		| 			| [ID]/[Name]		| first process listed is PID 1|
| docker save 		| -o		| 					| save an image as .tar|
| docker load 		| -i		| [Name]			| load a .tar image|
</details>

### Mariadb
The basic ideass are as follows:
1. Install mariadb manually because prebuilt images are forbidden[^8][^9]. This is done by the dockerfile. 
	- While at it, copy the configuration file and entrypoint script to a (general) location in the docker container and set up appropriate permissions.
	- Expose port for communication.
	- Specify the init script as the entrypoint.
2. The database initialization is the responsibiity of the script.
	- That includes creating the data dir, and setting ownership.
	- Running `mariadb-install-db`[^10].
	- Go through securing the installation by `mariadb-secure-installation`[^11].
3. The config file consists of whatever is necessary for the setup. 

Notes:
- ~~The terminal line to start mdb `mariadb --user=mysql --datadir=/var/lib/mysql` is put as CMD in the dockerfile (`CMD ["mariadb", "--user=mysql", "--datadir=/var/lib/mysql"]`) to delegate startups to the dockerfile and leave the init script to focus more on setups. The `exec "$@"` in theinit script executes the CMD from the dockerfile and also allows flexibility to override CMD.~~ Back to plan A, just exec in init script.

#### Dockerfile
- ~~Since the init script that is used as the entrypoint was made during testing (using bash as default in the shebang), so bash has to be installed along with mariadb server & client.~~ Just use sh/ash.
- Although setting file permissions using RUN may seem to be unnecessarily adding layers, but its safer and easier to make sure that all runs nicely.
- An alternate to docker hub to pull image if somehow dockerhub is down can be amazon[^12].
<details>
<summary>🗟 Dockerfile (mdb)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install mdb
RUN apk update && apk add \
	mariadb \
	mariadb-client \
	nano

#init script
COPY ./tools/mdb_init.sh /usr/local/bin/mdb_init.sh
RUN chmod +x /usr/local/bin/mdb_init.sh

#mdb config, overwrite it
COPY ./conf/mdb.cnf /etc/my.cnf.d/mariadb-server.cnf

#expose port (purely metadata)
#EXPOSE 3306

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]
#CMD ["mariadbd", "--user=mysql", "--datadir=/var/lib/mysql"]
```
</details>

#### Entrypoint script
The flow is as follows:
1. Start MariaDB in background (the daemon)
2. Run SQL setup commands (cant do this if the daemon is not running)
3. Stop background server
4. Start fresh MariaDB in foreground (to make it PID 1)

- `start_mdb_bg()` runs the command `mariadb-install-db` and creates the directories `/run/mysqld` adn `/var/lib/mysql` and sets up ownership/permissions, then runs the daemon.
- the function `apply_secure_fixes()` is basically running the `mariadb_secure_installation` manually.
- `setup_db()`
- then stops the daemon and `exec` mariadb as foreground process.

<details>
<summary>🗟 init script (mdb)</summary>

```sh
#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

echo -e "${CYA}Running mdb_init.sh${RES}"

start_mdb_bg()
{
	echo -e "${MAG}Installing/running mdb daemon${RES}"
	if [ ! -d /var/lib/mysql/mysql ]; then #create database (mysql is the standard)
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi
	mkdir -p /run/mysqld #-p avoids errors if it already exists
	chown -R mysql:mysql /run/mysqld /var/lib/mysql #set mysql user and group
	chmod u=rwx,g=,o= /run/mysqld #set permissions so only owner mysql can read/write/execute in dir to improve security.
	mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking=0 --port=${DB_PORT}& #mdb server daemon in bg, specify user, datadir, ensure networking is enabled
	sleep 5
	echo -e "${GRE}Installing/running mdb daemon...Done!${RES}"
}

#reproduce mysql_secure_installation noninteractively
apply_msi()
{
	echo -e "${MAG}Applying mysql_secure_installation manually${RES}"
	mariadb -e "DELETE FROM mysql.user WHERE User='';" #remove anon users
	mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" #allow only localhost/root access
	mariadb -e "DROP DATABASE IF EXISTS test;" #remove default test db
	mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" #Remove privileges related to it
	mariadb -e "FLUSH PRIVILEGES;" #apply immediately
	echo -e "${GRE}Applying mysql_secure_installation manually...Done!${RES}"
}

setup_db()
{
	local DB_USER_PW=$(cat /run/secrets/db_user_pw)
	echo -e "${MAG}Setting up the database${RES}"
	mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" #create db
	mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER_NAME}'@'%' IDENTIFIED BY '$DB_USER_PW';" #adds new user with password, allowing connection from any host ('%')
	mariadb -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'%';" #give full privilege to user
	mariadb -e "FLUSH PRIVILEGES;"
	echo -e "${GRE}Setting up the database...Done!${RES}"
}

start_mdb_bg
apply_msi
setup_db

# stop temporary background server
pkill -f mariadbd || true
sleep 1

echo -e "${GRE}MariaDB setup complete!${RES}"

# Start MariaDB server in the foreground (PID 1)
exec mariadbd --user=mysql --datadir=/var/lib/mysql --port=${DB_PORT}
# exec "$@"
```
</details>

#### Configs
- The config file consist of the allowed connections (all --> bind-address 0.0.0.0) and then put (copied) to the proper location (by the dockerfile). 
- Many configuration options can be passed as flags to mariadbd[^15].
- The location of the config file in alpine is not the same as in debian.

<details>
<summary>🗟configs (mdb)</summary>

```
[mariadbd]
bind-address = 0.0.0.0
#port = 3307 #can be changed to anything other than default (3306) --> use the script & .env to change
#skip-external-locking #if multiple mdb instances try modify same file simultaneously
#datadir = /var/lib/mysql #unnecessary?
#socket = /run/mysqld/mysqld.sock #unnecessary?
#skip-networking = 0 #unnecessary?
```
</details>

### Nginx
- Follows basically similar idea with mdb.
- the security cert is generated at runtime which are advantegeous in respect:
	- no key stored in the git repo
	- each environment gets a unique key (cluster comp, laptop, vm)
	- destroyed with docker-compose down -v, regenerated fresh
- but of course unstable and not reflective of real situation (that uses CA - Certificate Authority)

#### Dockerfile
-- Similar with mdb --
<details>
<summary>🗟Dockerfile (nginx)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install nginx
RUN apk update && apk add \
	nginx \
	openssl \
	nano curl gettext

#init script
COPY ./tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

#nginx config, NOT overwrite
COPY ./conf/nginx.cnf /etc/nginx/http.d/secure.conf.template

#expose port (none here, public exposure in docker-compose)

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]
# CMD [ "nginx", "-g", "daemon off;" ]
```
</details>

#### Entrypoint script
Sets up SSL?
<details>
<summary>🗟init script (nginx)</summary>

```sh
#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

echo -e "${CYA}Running nginx_init.sh${RES}"

#create directories
create_dirs()
{
	echo -e "${MAG}Creating directories${RES}"
	mkdir -p /etc/nginx/ssl #to store SSL/TLS certificates and keys
	mkdir -p /run/nginx #reate nginx run directory if it doesn't exist
	echo -e "${GRE}Creating directories...Done!${RES}"
}set_permissions()
{
	echo -e "${MAG}Setting permissions${RES}"
	chmod u=rw,go= /etc/nginx/ssl/server.key
	chmod u=rw,g=r,o=r /etc/nginx/ssl/server.crt
	echo -e "${GRE}Setting permissions...Done!${RES}"
}

#generate self-signed SSL certificate if it doesn't exist
# openssl req \ OpenSSL certificate request utility
# 		-x509 \ output a self-signed certificate instead of a certificate signing request (CSR)
# 		-newkey rsa:4096 \ generates a new RSA private key with 4096 bits of entropy
# 		-keyout /etc/nginx/ssl/server.key \ where to save the private key, must be secret and secure
# 		-out /etc/nginx/ssl/server.crt \ where to save the certificate, public cert that is sent to clients during the SSL handshake
# 		-days 365 \ certificate validity 
# 		-nodes \ create unencrypted private key. Otherwise, a passphrase would be prompted every time Nginx starts
# 		-subj "/C=DE/ST=Berlin/L=Berlin/O=42/CN=localhost" certificate subject information
generate_ss_ssl()
{
	if [ ! -f /etc/nginx/ssl/server.crt ]; then
		openssl req \
			-x509 \
			-newkey rsa:4096 \
			-keyout /etc/nginx/ssl/server.key \
			-out /etc/nginx/ssl/server.crt \
			-days 365 \
			-nodes \
			-subj "/C=DE/ST=Berlin/L=Berlin/O=42/CN=hsetyamu.42.fr"
	fi
}

#set permissions for SSL files
set_permissions()
{
	echo -e "${MAG}Setting permissions${RES}"
	chmod u=rw,go= /etc/nginx/ssl/server.key
	chmod u=rw,g=r,o=r /etc/nginx/ssl/server.crt
	echo -e "${GRE}Setting permissions...Done!${RES}"
}

#substitute environment variables into nginx config (to change ports)
setup_nginx_config()
{
	echo -e "${MAG}Setting Nginx config (port)${RES}"
	envsubst '${WP_PORT}' < /etc/nginx/http.d/secure.conf.template > /etc/nginx/http.d/secure.conf
	echo -e "${GRE}Nginx config (port)...Done!${RES}"
}

create_dirs
generate_ss_ssl
set_permissions
setup_nginx_config

echo -e "${GRE}nginx setup complete!${RES}"

# Start Nginx in the foreground/PID 1 (daemon off)
exec nginx -g "daemon off;"
# exec "$@"
```
</details>

#### Configs[^16]
- The default config file[^13][^14].
- The config file `nginx.cnf` is __not__ copied to the docker container (overwrite) in `/etc/nginx/nginx.conf` because that is the parent one, and in the last line _virtual hosts configs includes_ points to `/etc/nginx/http.d/*.conf`.

<details>
<summary>🗟configs (nginx)</summary>

```
server {
	#port to listen (443) in ipv4 & 6
	listen	443 ssl;
	listen	[::]:443 ssl;

	#which domain to respond
	server_name hsetyamu.42.fr localhost;

	#SSL certs-key & TLS
	ssl_certificate_key			/etc/nginx/ssl/server.key;
	ssl_certificate				/etc/nginx/ssl/server.crt;
	ssl_protocols				TLSv1.3;
	ssl_ciphers					HIGH:!aNULL:!MD5; #whitelist secure methods & blacklist insecure ones
	ssl_prefer_server_ciphers	on; #prioritize this over client's

	#root directory & index file
	root	/var/www/html;
	index	index.html index.php;

	#match every possible request (/) & check if file exists, if not then index at a directory, if still not found then 404
	location / {
		try_files	$uri $uri/ =404;
	}

	# Directive for every request that finishes with .php
	location ~ \.php$ {
		# Check if php file exists; if not, error 404 not found
		try_files	$uri =404;
		# Pass the .php files to the FPM listening on this address
		fastcgi_pass	wordpress:${WP_PORT};
		 # Set the script name
		fastcgi_index	index.php;
		# Include the necessary variables
		include			fastcgi_params;
		fastcgi_param	SCRIPT_FILENAME $document_root$fastcgi_script_name;
	}
}

#redirect http to https (because alpine opens 80 as default in /etc/nginx/http.d/default.conf)
server {
	listen 80;
	listen [::]:80;
	server_name hsetyamu.42.fr localhost;
	return 301 https://$server_name$request_uri;
}
```
</details>

### Wordpress
#### Dockerfile
- install lots of packages because alpine (debian only installs sevreal i think).
- getting WP-CLI[^17] to install wp in the script.
<details>
<summary>🗟Dockerfile (wp)</summary>mdb

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install php-fpm & utils
RUN apk update && apk add \
	php83 \
	php83-fpm \
	php83-mysqli \
	php83-json \
	php83-opcache \
	php83-gd \
	php83-pecl-imagick \
	php83-curl \
	php83-xml \
	php83-xmlreader \
	php83-simplexml \
	php83-zip \
	php83-dom \
	php83-iconv \ 
	php83-mbstring \
	php83-phar \
	php83-session \
	php83-openssl \
	php83-tokenizer \
	php83-fileinfo \
	openssl \
	imagemagick \
	icu-data-full \
	mariadb-client \
	curl nano gettext

#get wp-cli
RUN curl -o /usr/local/bin/wp-cli.phar \
	https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp-cli.phar && \
	mv /usr/local/bin/wp-cli.phar /usr/local/bin/wp

#init script
COPY ./tools/wp_init.sh /usr/local/bin/wp_init.sh
RUN chmod +x /usr/local/bin/wp_init.sh

#wp config, overwrite it later in the script
COPY ./conf/wp.conf /etc/php83/php-fpm.d/www.conf.template

#expose port (purely metadata)
#EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
# CMD ["php-fpm83", "-F"]
```
</details>

#### Entrypoint script
- the idea here is to wait for mdb to finish setting up, so the set -e (shell error is encountered) comes handy here so that if mdb container has not finished setting up, then connection can not be established (yet), the script will exit, then docker compose will restart it. Again and again until mdb container is finished, and connection can be established.
- wp is installed in 4 steps (via wp-cli)[^18]:
	1. `wp core download` somehow i need to change memory_limit first, otherwise cant download.
	2. `wp config create` generate config file (`/var/www/html/wp-config.php`).
	3. `wp db create` create db -- skipped because db is handled by mdb_container.
	4. `wp core install` install wp.

<details>
<summary>🗟init script (wp)</summary>

```sh
#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

echo -e "${CYA}Running wp_init.sh${RES}"

#change memory limit
change_limit()
{
	sed -i 's/^memory_limit = .*/memory_limit = 256M/' /etc/php83/php.ini
}

##substitute environment variables into php-fpm config (to change ports)
setup_php_config()
{
	echo -e "${MAG}Setting php-fpm config (port)${RES}"
	envsubst < /etc/php83/php-fpm.d/www.conf.template > /etc/php83/php-fpm.d/www.conf
	echo -e "${GRE}php-fpm config (port)...Done!${RES}"
}

#run core download (no wp-config.php yet)
wp_core_download()
{
	if [ ! -f /var/www/html/wp-load.php ]; then
		echo -e "${MAG}Downloading WordPress...${RES}"
		wp core download --allow-root --path=/var/www/html/
		echo -e "${GRE}Downloading WordPress...Done!${RES}"
	else
		echo -e "${YEL}WordPress already downloaded${RES}"
	fi
}

#generate config file
wp_config_create()
{
	local DB_USER_PW=$(cat /run/secrets/db_user_pw)
	if [ ! -f /var/www/html/wp-config.php ]; then
		echo -e "${MAG}Creating wp-config.php...${RES}"
		wp config create --allow-root \
			--path=/var/www/html/ \
			--dbname="${DB_NAME}" \
			--dbuser="${DB_USER_NAME}" \
			--dbpass="$DB_USER_PW" \
			--dbhost="${DB_HOST}:${DB_PORT}"
		echo -e "${GRE}Creating wp-config.php...Done!${RES}"
	else
		echo -e "${YEL}wp-config.php already exists${RES}"
	fi
}

#install wp
wp_core_install()
{
	local WP_ADM_PW=$(cat /run/secrets/wp_adm_pw)
	if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
		echo -e "${MAG}Installing WordPress...${RES}"
		wp core install --allow-root \
			--path=/var/www/html/ \
			--url="hsetyamu.42.fr" \
			--title="${WP_TITLE}" \
			--admin_user="${WP_ADM_USER}" \
			--admin_password="$WP_ADM_PW" \
			--admin_email="${WP_ADM_EMAIL}" \
			--skip-email
		echo -e "${GRE}Installing WordPress...Done!${RES}"
	else
		echo -e "${YEL}WordPress already installed${RES}"
	fi
}

wp_create_user()
{
	local WP_USER_PW=$(cat /run/secrets/wp_user_pw)
	if ! wp user get "$WP_USER" --allow-root --path=/var/www/html 2> /dev/null; then
		echo -e "${MAG}Creating user...${RES}"
		wp user create "$WP_USER" "$WP_USER_EMAIL" \
			--path=/var/www/html \
			--role=editor \
			--user_pass="$WP_USER_PW" \
			--allow-root
		echo -e "${GRE}Creating user...Done!${RES}"
	else
		echo -e "${YEL}Creating user fails!${RES}"
	fi
}

#set permissions
set_permissions()
{
	echo -e "${MAG}Setting permissions${RES}"
	chown -R nobody:nogroup /var/www/html
	chmod -R u=rwx,go=rx /var/www/html
	echo -e "${GRE}Setting permissions...Done!${RES}"
}

change_limit
setup_php_config
wp_core_download
wp_config_create
wp_core_install
wp_create_user
set_permissions

echo -e "${GRE}WordPress setup complete!${RES}"

#start PHP-FPM in foreground
exec php-fpm83 -F
# exec "$@"
```
</details>

#### Configs
- overwrite www.conf (pool configuration files) that is read by default by PHP-FPM as defined in `/etc/php82/php-fpm.conf`.

<details>
<summary>🗟configs (wp)</summary>

```
[www]
; PHP-FPM pool name
listen = 0.0.0.0:${WP_PORT}
;listen.allowed_clients = 127.0.0.1,nginx

; User and group
user = nobody ;default
group = nogroup ;default

; Process manager
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

; Logging
access.log = /proc/self/fd/1
catch_workers_output = yes

; Clear environment
clear_env = no

; PHP settings
php_value[display_errors] = off
php_value[log_errors] = on
php_value[upload_max_filesize] = 64M
php_value[post_max_size] = 64M
php_value[memory_limit] = 512M
```
</details>

### Docker Compose
<details>
<summary>🗟docker-compose.yml</summary>

```docker

services:
  mariadb:
    image: mdb:inc42
    build:
      context: requirements/mariadb/
      dockerfile: Dockerfile
    container_name: mdb_cont
    volumes:
      - mdb_data:/var/lib/mysql
    environment:
      DB_NAME: ${DB_NAME}
      DB_USER_NAME: ${DB_USER_NAME}
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT}
    networks:
      - inception
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mariadb-admin", "ping", "-h", "localhost"]
      interval: 20s
      timeout: 5s
      retries: 3
    secrets:nobody:nogroup
      - db_user_pw

  wordpress:
    image: wp:inc42
    build:
      context: requirements/wordpress/
      dockerfile: Dockerfile
    container_name: wp_cont
    volumes:
      - wp_data:/var/www/html
    environment:
      DB_NAME: ${DB_NAME}
      DB_USER_NAME: ${DB_USER_NAME}
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT}
      WP_TITLE: ${WP_TITLE}
      WP_ADM_USER: ${WP_ADM_USER}
      WP_ADM_EMAIL: ${WP_ADM_EMAIL}
      WP_PORT: ${WP_PORT}
      WP_USER: ${WP_USER}
      WP_USER_EMAIL: ${WP_USER_EMAIL}
    networks:
      - inception
    depends_on:
      mariadb:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      #test: ["CMD-SHELL", "netstat -tnlp | grep :${WP_PORT} || exit 1"]
      #test: ["CMD-SHELL", "test -S /run/php-fpm.sock || exit 1"]
      test: ["CMD-SHELL", "wp core is-installed --allow-root --path=/var/www/html > /dev/null 2>&1 || exit 1"]
      interval: 20s
      timeout: 5s
      retries: 3
    secrets:
      - db_user_pw
      - wp_adm_pw
      - wp_user_pw

  nginx:
    image: nginx:inc42
    build:
      context: requirements/nginx/
      dockerfile: Dockerfile
    container_name: nginx_cont
    volumes:
      - wp_data:/var/www/html
    environment:
      WP_PORT: ${WP_PORT}
    networks:
      - inception
    depends_on:
      wordpress:
        condition: service_healthy
      mariadb:
        condition: service_healthy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    healthcheck:
      test: ["CMD", "curl", "-kfI", "https://localhost:443"]
      interval: 20s
      timeout: 5s
      retries: 3

volumes:
  mdb_data:
    driver: local
  wp_data:
    driver: local

networks:
  inception:
    driver: bridge

secrets:
  db_user_pw:
    file: ../secrets/db_user_pw
  wp_adm_pw:
    file: ../secrets/wp_adm_pw
  wp_user_pw:
    file: ../secrets/wp_user_pw
```
</details>

#### Worth mentioning
- __.env__[^20] useful to put all variables that can be easily changed (but not sensitive info because it can be inspected. 
- __Secrets__[^19] are case sensitive, filename and such, be careful. Useful for sensitive info (passwords) --> does not show with `docker inspect [container]`.
- __Healthcheck__ just an arbitrary test parameter to run periodically. A repeated 0 exit status of the check means healthy. 
- __depends-on__ useful to start (NOT create) a service __after__ another (healthy) service has been started.
- - __ports__ publishing ports outside the network. `docker ps` lists only the json file, and EXPOSE in the dockerfile just writes the metadata to this file. Without EXPOSE in the dockerfiles, intercontainer communication is left to the default of each services. This can be checked by `docker exec [container] netstat -tnl`.
- on topic of ports, leaving the default is definitely the best practice. Changing them is unnecessarily tangled since it involves changing the configurations of the related containers, e.g mdb <--port--> wp or wp(php-fpm) <--port--> nginx, though however, the definition can be conviniently put as environmental variable in .env file. I do it because I'm already in too deep here. So as it stands currently, the script and docker-compose files are more complicated as they should be because i need to add a functionality (`envsubst`) to change the content of the config file on the fly which in turn requires the installation of another package (`gettext`) and providing unnecessary clutter to the docker-compose because i have to specify the env vars.

### Notes
- I decided to just use the initsrcipt on each dockerfile as the ENTRYPOINT and ditched CMD (along with `exec "$@"` in the script) because although that works fine for mdb and nginx but wp the PID 1 would just be the script :
	```sh
	~/workspace/Inception $ docker exec mdb_container ps aux
	PID		USER	TIME	COMMAND
	1		mysql	0:00	mariadbd --user=mysql --datadir=/var/lib/mysql
	~/workspace/Inception $ docker exec nginx_container ps aux
	PID		USER	TIME	COMMAND
	1		root	0:00	nginx: master process nginx -g daemon off;
	~/workspace/Inception $ docker exec wp_container ps aux
	PID		USER	TIME	COMMAND
	1		root	0:00	{wp_init.sh} /bin/bash /usr/local/bin/wp_init.sh php-fpm83 -F
	```
- So i just use the `exec` the command directly to run them to the foreground:
	```sh
	~/workspace/Inception $ docker exec mdb_container ps aux
	PID		USER	TIME	COMMAND
	1		mysql	0:00	mariadbd --user=mysql --datadir=/var/lib/mysql
	~/workspace/Inception $ docker exec nginx_container ps aux
	PID		USER	TIME	COMMAND
	1		root	0:00	nginx: master process nginx -g daemon off;
	~/workspace/Inception $ docker exec wp_container ps aux
	PID		USER	TIME	COMMAND
	1		root	0:00	{php-fpm83} php-fpm: master process (/etc/php83/php-fpm.conf)
	```
- Users & groups are left as default (nobody for wp, nginx for nginx)

- Some utilities
```sh
netstat -tnlp #t = TCP conns only, n = numeric IP (not hostnames), l = only LISTENING ports, p = process on that port
nc -zv #z = zero-I/O mode (just check if port is open, don't send/receive ), v = verbose
curl -kfI #k = skip verifyng certs, f = fail silently on errors (exit code 22 on 4xx/5xx), I = headers only
set -e #when (any) command fails, exit immediately
echo -e #enable interpretation of backslahes, for colours
nginx -t #check nginx config file
envsubst #substitutes environment variables in shell format strings
```
## Evals


## Terminology overload
🐳 Docker & Containers
- __Docker__ A platform that runs applications inside isolated environments called containers.
- __Container__ A lightweight, isolated process that contains its own filesystem, packages, and configuration.
- __Docker Image__ A read-only blueprint used to create containers. Built from a Dockerfile.
- __Dockerfile__ A script that defines how to build a Docker image (what OS, what packages, what commands).
- __PID 1__ The “main” process inside a Docker container. If PID 1 exits → the container stops.
- __Bind mount__ A host folder mounted directly into a container.
- __Volume__ A persistent storage area created and managed by Docker.

🕸️ Networking & Services
- __Entry Point__ The container that receives all external traffic (must be NGINX in Inception).
- __Reverse Proxy__ A server that receives requests and forwards them to another internal service (NGINX forwards PHP requests to PHP-FPM).
- __TLS/SSL__ _Transport Layer Security/Secure Sockets Layer_. Encryption technology for HTTPS communication.
- __Ports__ Channels used for network communication.
- __Local IP__ Your machine’s internal IP, used for local DNS mapping.

🌐 NGINX / FastCGI / PHP
- __NGINX__ A high-performance web server used as the only entry point in the project.
- __FastCGI__ _Common Gateway Interface_. A protocol that lets NGINX communicate with a backend like PHP-FPM.
- __PHP-FPM__ _FastCGI Process Manager_. Runs PHP scripts in the background and communicates with NGINX.
- __php-fpm socket__ A special file for communication between NGINX and PHP-FPM, e.g.: `/var/run/php/php8.2-fpm.sock`

🛢️ MariaDB / MySQL
- __MariaDB__ It’s a drop-in replacement for MySQL.
- __mysqld / mariadbd__ The actual database server daemon running in the background.
- __mysql / mariadb (client)__ The command-line program used to interact with the server.

🔐 Security & Secrets
- __Environment variables__ Variables injected into containers at runtime via .env or docker-compose. Used for non-secret values.
- __Docker Secrets__ Secure encrypted storage for sensitive data (passwords). Mounted into /run/secrets/....
- __.env file__ A file storing environment variables used by docker-compose.

🗂️ Linux / Filesystems / Tools
- __Alpine Linux__ A lightweight Linux distribution often used in Docker images.
- __BusyBox__ A minimal collection of Unix utilities (ls, cp, mv…) found in Alpine.
- __OpenRC__ The init system used by Alpine Linux (not used in Inception; avoid it).
- __Daemon__ A background service (like MariaDB, PHP-FPM).
- __exec (Bash)__ Replaces the current process with a new one. Used to make the final server process become PID 1.

## References
[^1]: https://itsfoss.com/alpine-linux-virtualbox/
[^2]: https://krython.com/post/installing-alpine-linux-in-virtualbox/
[^3]: https://wiki.alpinelinux.org/wiki/Kernels
[^4]: https://wiki.alpinelinux.org/wiki/Xfce
[^5]: https://wiki.alpinelinux.org/wiki/VirtualBox_shared_folders
[^6]: https://dockerlabs.collabnix.com/docker/cheatsheet/
[^7]: https://dev.mysql.com/doc/refman/8.4/en/mysql-secure-installation.html
[^8]: https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/creating-a-custom-container-image
[^9]: https://wiki.alpinelinux.org/wiki/MariaDB
[^10]: https://mariadb.com/docs/server/clients-and-utilities/deployment-tools/mariadb-install-db
[^11]: https://mariadb.com/docs/server/clients-and-utilities/deployment-tools/mariadb-secure-installation
[^12]: https://gallery.ecr.aws/docker/library/alpine
[^13]: https://wiki.alpinelinux.org/wiki/Nginx
[^14]: https://hub.docker.com/_/nginx
[^15]: https://hub.docker.com/_/mariadb
[^16]: https://nginx.org/en/docs/beginners_guide.html
[^17]: https://make.wordpress.org/cli/handbook/guides/installing/
[^18]: https://make.wordpress.org/cli/handbook/how-to/how-to-install/
https://wiki.alpinelinux.org/wiki/WordPress
https://hub.docker.com/_/wordpress
[^19]: https://serverfault.com/a/936262
[^20]: https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/


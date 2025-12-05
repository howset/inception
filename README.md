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
	- [Useful checks](#useful-checks)
- [Docker containers](#docker-containers)
	- [Mariadb](#mariadb)
		- [Dockerfile](#dockerfile)
		- [Entrypoint script](#entrypoint-script)
		- [Configs](#configs)
		- [Exploring mdb](#exploring-mdb)
	- [Nginx](#nginx)
		- [Dockerfile](#dockerfile-1)
		- [Entrypoint script](#entrypoint-script-1)
		- [Configs](#configs-1)
		- [Exploring nginx](#exploring-nginx)
	- [Wordpress](#wordpress)
		- [Dockerfile](#dockerfile-2)
		- [Entrypoint script](#entrypoint-script-2)
		- [Configs](#configs-2)
		- [Exploring wp](#exploring-wp)
	- [Docker Compose](#docker-compose)
		- [Worth mentioning](#worth-mentioning)
	- [Notes](#notes)
- [Bonus](#bonus)
	- [Static page](#static-page)
		- [Dockerfile](#dockerfile-3)
		- [Script](#script)
		- [Confs](#confs)
		- [Using static page](#using-static-page)
	- [Redis cache](#redis-cache)
		- [Dockerfile](#dockerfile-4)
		- [Script](#script-1)
		- [Confs](#confs-1)
		- [Using Redis](#using-redis)
	- [Adminer](#adminer)
		- [Dockerfile](#dockerfile-5)
		- [Script](#script-2)
		- [Confs](#confs-2)
		- [Using Adminer](#using-adminer)
	- [FTP server](#ftp-server)
		- [Dockerfile](#dockerfile-6)
		- [Script](#script-3)
		- [Confs](#confs-3)
		- [Using ftp](#using-ftp)
	- [Portainer](#portainer)
		- [Dockerfile](#dockerfile-7)
		- [Script](#script-4)
		- [Confs](#confs-4)
		- [Using portainer](#using-portainer)
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
- 🥇 https://github.com/cfareste/Inception

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
	memory 4096MB --> 2048 actually suffices
	HD 20GB
	processors 4 --> 1 or 2 is enough
	```
	- Allocating too much resources would just make the startup slower, alpine linux is crazy small. The large allocation just make more initialization overhead.
	- On the other hand, with minimal resources, using GUI on Alpine may put too much pressure and makes it hangs (though SSH from host machine works just fine). For example opening only 2 instances of firefox and geany often meets this problem. Speculation: firefox doesnt work well with musl based alpine.
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
	- `docker` is the core docker engine
	- `docker-cli-compose` is the compose plugin (`Docker Compose`)
	- `docker-compose` deprecated, can be skipped.
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

### Useful checks
- `sudo ncdu /` use sudo to also check dirs that would otherwise be hidden.
- `free -h` check free memory
- `ps aux` check PID
- `curl -L` follow redirects

## Docker containers
- The base image can basically be from anything, either from debian:bookworm or alpine:3.21.1 as long as the kernel is the same (linux), the difference is the size of the image using alpine ended up smaller than debian (~200 MB vs ~500 MB), and some adjustments also has to be made due to some differences between the systems (e.g. alpine has no bash by default).
- __EXPOSE__ in dockerfiles means nothing other than metadata for documentation. Since this project doesnt really say anything about the port to be used for connections between the containers (other than in the diagram, which uses the default ports for the services i.e. mariadb 3306 and php-fpm 9000), using the defaults would work just fine, namely not defining anything in the dockerfile (See Docker Compose below).
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
| docker system		| info		| 					| system wide info|
| docker system		| df		| 					| docker disk usage|
| docker inspect	| 			| [ID]/[Name]		| inspect an image/a container|
| docker builder	| prune -f	| 					| remove cache|

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
- The db has to have a root password because otherwise its insecure.
- Persistence test requires checks to see if database has been established before (in the script), because if it has, then running the entrypoint script again would result in errors. 

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

DB_USER_PW=$(cat /run/secrets/db_user_pw)
DB_ROOT_PW=$(cat /run/secrets/db_root_pw)
MSI_FLAG="/var/lib/mysql/.msi_flag"
SDB_FLAG="/var/lib/mysql/.sdb_flag"

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
	if [ ! -f "$MSI_FLAG" ]; then
		echo -e "${MAG}Applying mysql_secure_installation manually${RES}"
		mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$DB_ROOT_PW');"
		mariadb -u root -p"$DB_ROOT_PW" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
		mariadb -u root -p"$DB_ROOT_PW" -e "DELETE FROM mysql.user WHERE User='';"
		mariadb -u root -p"$DB_ROOT_PW" -e "DROP DATABASE IF EXISTS test;"
		mariadb -u root -p"$DB_ROOT_PW" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
		mariadb -u root -p"$DB_ROOT_PW" -e "FLUSH PRIVILEGES;"
		echo -e "${GRE}Applying mysql_secure_installation manually...Done!${RES}"
		touch "$MSI_FLAG"
		chown mysql:mysql "$MSI_FLAG"
	else 
		echo -e "${YEL}Not applying mysql_secure_installation again${RES}"
	fi
}

setup_db()
{
	if [ ! -f "$SDB_FLAG" ]; then
		echo -e "${MAG}Setting up the database${RES}"
		mariadb -u root -p"$DB_ROOT_PW" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" #create db
		mariadb -u root -p"$DB_ROOT_PW" -e "CREATE USER IF NOT EXISTS '${DB_USER_NAME}'@'%' IDENTIFIED BY '$DB_USER_PW';" #adds new user with password, allowing connection from any host ('%')
		mariadb -u root -p"$DB_ROOT_PW" -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'%';" #give full privilege to user
		mariadb -u root -p"$DB_ROOT_PW" -e "FLUSH PRIVILEGES;"
		echo -e "${GRE}Setting up the database...Done!${RES}"
		touch "$SDB_FLAG"
		chown mysql:mysql "$SDB_FLAG"
	else 
		echo -e "${YEL}Not Setting up the database again${RES}"
	fi
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

```sql
[mariadbd]
bind-address = 0.0.0.0
#port = 3307 #can be changed to anything other than default (3306) --> use the script & .env to change
#skip-external-locking #if multiple mdb instances try modify same file simultaneously
#datadir = /var/lib/mysql #unnecessary?
#socket = /run/mysqld/mysqld.sock #unnecessary?
#skip-networking = 0 #unnecessary?
```
</details>

#### Exploring mdb
<details>
<summary>🗟open/test database</summary>

```sql
# Enter MariaDB container shell
docker exec -it mdb_cont sh

# Connect as root (password from secret)
mariadb -u root -p
# (paste root password if you set one; if none, just press Enter)

# List databases
SHOW DATABASES;

# Select WordPress DB
USE ${DB_NAME};

# List tables
SHOW TABLES;

# Inspect a table structure
DESCRIBE wp_users;
DESCRIBE wp_options;

# Check stored site URL
SELECT option_value FROM wp_options WHERE option_name='siteurl';

# List users (MariaDB level)
SELECT User, Host FROM mysql.user;

# Show privileges for WP user
SHOW GRANTS FOR '${DB_USER_NAME}'@'%';

# Count posts/comments
SELECT COUNT(*) FROM wp_posts WHERE post_type='post';
SELECT COUNT(*) FROM wp_comments;

# Insert test post directly (bypassing WP)
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title,
 post_status, comment_status, ping_status, post_name, post_type)
VALUES (1, NOW(), NOW(), 'DB inserted content', 'DB Post', 'publish', 'open', 'closed', 'db-post', 'post');

# Verify it appears
SELECT ID, post_title, post_date FROM wp_posts ORDER BY ID DESC LIMIT 3;

# Exit mysql client
EXIT;

# From host: quick connectivity test
docker exec mdb_cont mysql -u ${DB_USER_NAME} -p$(cat secrets/db_user_pw) -e "SHOW TABLES;" ${DB_NAME}

# Show server variables (sample)
docker exec mdb_cont mysql -e "SHOW VARIABLES LIKE 'port';"
```
</details>

### Nginx
- Follows basically similar idea with mdb.
- The security cert is generated at runtime which are advantegeous in respect:
	- no key stored in the git repo
	- each environment gets a unique key (cluster comp, laptop, vm)
	- destroyed with docker-compose down -v, regenerated fresh
- but of course unstable (changes all the time) and not reflective of real situation (that uses CA - Certificate Authority)

#### Dockerfile
- Follows the same idea overall:
	- from a base image,
	- install necessary packages,
	- then deal with setting up the init script,
	- the configs too,
	- then entrypoint
- Since there is a bonus, an additional config file has to be copied too, but separately (to a temp directory)

<details>
<summary>🗟Dockerfile (nginx)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install nginx
RUN apk update && apk add --no-cache\
	nginx \
	openssl \
	nano curl

#init script
COPY ./tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

#nginx config, NOT overwrite
COPY ./conf/nginx.cnf /etc/nginx/http.d/secure.conf

#bonus for adminer & portainer
COPY ./conf/adminer_bonus.cnf /temp/adminer_bonus.conf
COPY ./conf/portainer_bonus.cnf /temp/portainer_bonus.conf

#expose port (none here, public exposure in docker-compose)
#EXPOSE 80 443

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]
# CMD [ "nginx", "-g", "daemon off;" ]

```
</details>

#### Entrypoint script
- The accompanying bonus conf (adminer_bonus.cnf) is first copied by the dockerfile to a temp dir. If adminer is detected to be up and running, then this bonus conf file can be copied to nginx conf file location.
- Of course nginx has to be recreated, this is handled by the makefile.

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
	echo -e "${MAG}Generating self-signed certs...${RES}"
	if [ ! -f /etc/nginx/ssl/server.crt ]; then
		openssl req \
			-x509 \
			-newkey rsa:4096 \
			-keyout /etc/nginx/ssl/server.key \
			-out /etc/nginx/ssl/server.crt \
			-days 365 \
			-nodes \
			-subj "/C=DE/ST=Berlin/L=Berlin/O=42/CN=${DOMAIN_NAME}" \
			-addext "subjectAltName=DNS:${DOMAIN_NAME},DNS:localhost"
		echo -e "${GRE}Generating self-signed certs...Done!${RES}"
	else
		echo -e "${YEL}Found existing certs!${RES}"
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
	sed -i "s|\${WP_PORT}|${WP_PORT}|g" /etc/nginx/http.d/secure.conf
	echo -e "${GRE}Nginx config (port)...Done!${RES}"
	echo -e "${MAG}Setting Nginx config (domain name)${RES}"
	sed -i "s|\${DOMAIN_NAME}|${DOMAIN_NAME}|g" /etc/nginx/http.d/secure.conf
	echo -e "${GRE}Nginx config (domain name)...Done!${RES}"
}

check_bonus_setup()
{
	if nc -zv adminer 8080 >/dev/null 2>&1; then
		echo -e "${MAG}Setting up adminer (bonus) config...${RES}"
		mkdir -p /etc/nginx/bonus.d
		cp /temp/adminer_bonus.conf /etc/nginx/bonus.d/adminer_bonus.conf
		echo -e "${GRE}Setting up adminer (bonus) config...Done!${RES}"
	fi
	if nc -zv portainer 9443 >/dev/null 2>&1; then
		echo -e "${MAG}Setting up portainer (bonus) config...${RES}"
		cp /temp/portainer_bonus.conf /etc/nginx/bonus.d/portainer_bonus.conf
		echo -e "${GRE}Setting up portainer (bonus) config...Done!${RES}"
	fi
}

create_dirs
generate_ss_ssl
set_permissions
setup_nginx_config
check_bonus_setup

echo -e "${GRE}nginx setup complete!${RES}"

# Start Nginx in the foreground/PID 1 (daemon off)
exec nginx -g "daemon off;"
# exec "$@"
```
</details>

#### Configs[^16]
- The default config file[^13][^14].
- The config file `nginx.cnf` is __not__ copied to the docker container (overwrite) in `/etc/nginx/nginx.conf` because that is the parent one, and in the last line _virtual hosts configs includes_ points to `/etc/nginx/http.d/*.conf`.
- ~~The adminer/portainer config file is put in a different directory that will be inspected by the include line in the secure.conf (nginx conf file).~~ now have their own block for each to have it's respective subdomain. --> this has to be accompanied by changes in /etc/hosts too.

<details>
<summary>🗟configs (nginx)</summary>

```
server {
	#port to listen (443) in ipv4 & 6
	listen	443 ssl;
	listen	[::]:443 ssl;

	#which domain to respond
	server_name ${DOMAIN_NAME};

	#SSL certs-key & TLS
	ssl_certificate_key			/etc/nginx/ssl/server.key;
	ssl_certificate				/etc/nginx/ssl/server.crt;
	ssl_protocols				TLSv1.3;
	ssl_ciphers					HIGH:!aNULL:!MD5; #whitelist secure methods & blacklist insecure ones
	ssl_prefer_server_ciphers	on; #prioritize this over client's

	#root directory & index file
	root	/var/www/html;
	index	index.html index.php;

	#try to serve exact file, if not found try as directory, if still not found then 404
	location / {
		try_files $uri $uri/ =404;
	}

	#try to serve exact file, if not found try as directory, if still not found fallback to /index.php?$args
#	location / {
#		try_files	$uri $uri/ /index.php?$args;
#	}

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

	# Include bonus service locations if they exist
	include /etc/nginx/bonus.d/*.conf;
}

#redirect https://localhost to https://${DOMAIN_NAME}
server {
	listen	443 ssl;
	listen	[::]:443 ssl;

	#which domain to respond
	server_name localhost;

	ssl_certificate_key			/etc/nginx/ssl/server.key;
	ssl_certificate				/etc/nginx/ssl/server.crt;
	ssl_protocols				TLSv1.3;

	# Redirect all requests to domain
	return 301 https://server_name$request_uri;
}

#redirect http://localhost to https://${DOMAIN_NAME} (because alpine opens 80 as default in /etc/nginx/http.d/default.conf)
server {
	listen 80;
	listen [::]:80;
	server_name ${DOMAIN_NAME} localhost;
	return 301 https://$server_name$request_uri;
}

```
</details>

<details>
<summary>🗟configs (adminer)</summary>

```
location /adminer/ {
	proxy_pass http://adminer:8080/;
	proxy_set_header Host $host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto $scheme;
}
```
</details>

<details>
<summary>🗟configs (portainer)</summary>

```
location /portainer/ {
	proxy_pass http://portainer:9000/;
	proxy_http_version 1.1;

	# WebSocket support
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";

	# Basic headers
	proxy_set_header Host $http_host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto https;

	# Disable buffering
	proxy_buffering off;
}
```
</details>

#### Exploring nginx
I dont know what to do here other than checking `nginx -t #check nginx config file`.

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
	curl nano

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
- The idea here is to wait for mdb to finish setting up, so the set -e (shell error is encountered) comes handy here so that if mdb container has not finished setting up, then connection can not be established (yet), the script will exit, then docker compose will restart it. Again and again until mdb container is finished, and connection can be established. --> Not anymore, use healthcheck and dependencies in the docker-compose.
- wp is installed in 4 steps (via wp-cli)[^18]:
	1. `wp core download` somehow i need to change memory_limit first, otherwise cant download.
	2. `wp config create` generate config file (`/var/www/html/wp-config.php`).
	3. `wp db create` create db -- skipped because db is handled by mdb_container.
	4. `wp core install` install wp.
- Additionally, a function to check if the bonus redis plugin should be connected and enabled --> works more or less like adminer and nginx.

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
	echo -e "${MAG}Changing memory limit...${RES}"
	sed -i "s/^memory_limit = .*/memory_limit = 256M/" /etc/php83/php.ini
	echo -e "${MAG}Changing memory limit...Done!${RES}"
}

#substitute environment variables into php-fpm config (to change ports)
setup_php_config()
{
	echo -e "${MAG}Setting php-fpm config (port)...${RES}"
	sed -i "s|\${WP_PORT}|${WP_PORT}|g" /etc/php83/php-fpm.d/www.conf
	echo -e "${GRE}Setting php-fpm config (port)...Done!${RES}"
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
	local WP_MAD_PW=$(cat /run/secrets/wp_mad_pw)
	if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
		echo -e "${MAG}Installing WordPress...${RES}"
		wp core install --allow-root \
			--path=/var/www/html/ \
			--url="${DOMAIN_NAME}" \
			--title="${WP_TITLE}" \
			--admin_user="${WP_MAD_USER}" \
			--admin_password="$WP_MAD_PW" \
			--admin_email="${WP_MAD_EMAIL}" \
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
		echo -e "${YEL}Creating user fails (already exists)!${RES}"
	fi
}

wp_configure_comments()
{
	echo -e "${MAG}Configure comment settings...${RES}"
	wp option update comment_whitelist 0 --allow-root --path=/var/www/html
	echo -e "${GRE}Configure comment settings...Done!!${RES}"
}

#set permissions
set_permissions()
{
	echo -e "${MAG}Setting permissions${RES}"
	#chown -R nobody:nogroup /var/www/html #user with least permission, std in alpine
	chown -R nobody:www-data /var/www/html #std group name used by web servers 
	chmod -R ug=rwx,o=rx /var/www/html
	echo -e "${GRE}Setting permissions...Done!${RES}"
}

#if redis_cont is up, then install plugin in the wp_cont side, set it up, and enable it. (bonus)
connect_redis()
{
	if nc -zv redis 6379 >/dev/null 2>&1; then
		echo -e "${MAG}Connecting redis...${RES}"
		wp plugin install redis-cache --activate --allow-root --path=/var/www/html
		wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/html
		wp config set WP_REDIS_PORT 6379 --raw --allow-root --path=/var/www/html
		wp redis enable --allow-root --path=/var/www/html
		echo -e "${GRE}Connecting redis...Done!${RES}"
	fi
}

change_limit
setup_php_config
wp_core_download
wp_config_create
wp_core_install
wp_create_user
wp_configure_comments
set_permissions
connect_redis

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

#### Exploring wp
- check through the browser i guess?

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
      - inc_net
    restart: unless-stopped
    healthcheck:
      # test: ["CMD", "mariadb-admin", "ping", "-h", "localhost"]
      test: ["CMD-SHELL", "netstat -tuln | grep :${DB_PORT}"]
      interval: 10s
      timeout: 5s
      retries: 3
    secrets:
      - db_user_pw
      - db_root_pw

  wordpress:
    image: wp:inc42
    build:
      context: requirements/wordpress/
      dockerfile: Dockerfile
    container_name: wp_cont
    volumes:
      - wp_data:/var/www/html
    environment:
      DOMAIN_NAME: ${DOMAIN_NAME}
      DB_NAME: ${DB_NAME}
      DB_USER_NAME: ${DB_USER_NAME}
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT}
      WP_TITLE: ${WP_TITLE}
      WP_MAD_USER: ${WP_MAD_USER}
      WP_MAD_EMAIL: ${WP_MAD_EMAIL}
      WP_PORT: ${WP_PORT}
      WP_USER: ${WP_USER}
      WP_USER_EMAIL: ${WP_USER_EMAIL}
    networks:
      - inc_net
    depends_on:
      mariadb:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp | grep :${WP_PORT}"]
      #test: ["CMD-SHELL", "wp core is-installed --allow-root --path=/var/www/html > /dev/null 2>&1 || exit 1"]
      interval: 5s
      timeout: 2s
      retries: 3
    secrets:
      - db_user_pw
      - wp_mad_pw
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
      DOMAIN_NAME: ${DOMAIN_NAME}
      WP_PORT: ${WP_PORT}
    networks:
      - inc_net
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
      # test: ["CMD", "curl", "-kfI", "https://localhost:443"]
      test: ["CMD-SHELL", "netstat -tuln | grep :443"]
      interval: 3s
      timeout: 2s
      retries: 3

  staticpage:
    profiles: ["bonus"]
    image: staticpage:inc42
    build:
      context: requirements/bonus/static_page
      dockerfile: Dockerfile
    container_name: staticp_cont
    volumes:
      - wp_data:/var/www/html
    networks:
      - inc_net
    restart: "no"

  redis:
    profiles: ["bonus"]
    image: redis:inc42
    build:
      context: requirements/bonus/redis
      dockerfile: Dockerfile
    container_name: redis_cont
    volumes:
    - redis_data:/data
    networks:
      - inc_net
    depends_on:
      wordpress:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      # test: ["CMD", "redis-cli", "ping"]
      test: ["CMD-SHELL", "netstat -tuln | grep :6379"]
      interval: 5s
      timeout: 2s
      retries: 3

  adminer:
    profiles: ["bonus"]
    image: adminer:inc42
    build:
      context: requirements/bonus/adminer
      dockerfile: Dockerfile
    container_name: adminer_cont
    networks:
      - inc_net
    restart: unless-stopped
    depends_on:
      mariadb:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "netstat -tuln | grep :8080"]
      interval: 10s
      timeout: 5s
      retries: 3

  vsftpd:
    profiles: ["bonus"]
    image: vsftpd:inc42
    build:
      context: requirements/bonus/vsftpd
      dockerfile: Dockerfile
    container_name: vsftpd_cont
    ports:
      - "21:21"
      - "21000-21010:21000-21010"
    volumes:
      - wp_data:/home/${FTP_USER}/wordpress
    networks:
      - inc_net
    environment:
      FTP_USER: ${FTP_USER}
    secrets:
      - ftp_pw
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "netstat -tuln | grep :21"]
      interval: 10s
      timeout: 5s
      retries: 3

  portainer:
    profiles: ["bonus"]
    image: portainer:inc42
    build:
      context: requirements/bonus/portainer
      dockerfile: Dockerfile
    container_name: portainer_cont
    ports:
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - inc_net
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "netstat -tuln | grep :9443"]
      interval: 30s
      timeout: 3s
      retries: 3

volumes:
  mdb_data:
    name: mdb_vol
    driver: local
  wp_data:
    name: wp_vol
    driver: local
  redis_data:
    name: redis_vol
    driver: local

networks:
  inc_net:
    name: inc_net
    driver: bridge

secrets:
  db_user_pw:
    file: ${DB_USER_PW}
  db_root_pw:
    file: ${DB_ROOT_PW}
  wp_mad_pw:
    file: ${WP_MAD_PW}
  wp_user_pw:
    file: ${WP_USER_PW}
  ftp_pw:
    file: ${FTP_PW}
```
</details>

#### Worth mentioning
- __.env__[^20] useful to put all variables that can be easily changed (but not sensitive info because it can be inspected. 
- __Secrets__[^19] are case sensitive, filename and such, be careful. Useful for sensitive info (passwords) --> does not show with `docker inspect [container]`.
- __Healthcheck__ just an arbitrary (can be anything, hopefully relevant) test parameter to run periodically. A repeated 0 exit status of the check means healthy. 
- __depends-on__ useful to start (NOT create) a service __after__ another (healthy) service has been started.
- __ports__ publishing ports outside the network. `docker ps` lists only the json file, and EXPOSE in the dockerfile just writes the metadata to this file. Without EXPOSE in the dockerfiles, intercontainer communication is left to the default of each services. This can be checked by `docker exec [container] netstat -tnl`.
- on topic of ports, leaving the default is definitely the best practice. Changing them is unnecessarily tangled since it involves changing the configurations of the related containers, e.g mdb <--port--> wp or wp(php-fpm) <--port--> nginx, though however, the definition can be conviniently put as environmental variable in .env file. I do it because I'm already in too deep here. So as it stands currently, the script and docker-compose files are more complicated as they should be ~~because i need to add a functionality (`envsubst`) to change the content of the config file on the fly which in turn requires the installation of another package (`gettext`) and providing unnecessary clutter to the docker-compose because i have to specify the env vars.~~ now just use sed, avoid installing a new package, but just as unnecessarily tangled.

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
envsubst #substitutes environment variables in shell format strings, not used anymore
curl -v http://localhost:80 #just check the result of a connection
```

## Bonus
- The location is very weird --> srcs/requirements/bonus/. I would intuitively think if there is a requirement directory, then a bous directory would be on the same level (so srcs/bonus/), not under it.

### Static page
- Made a mock cv page by pirating a freely available template from the interwebs.
- Copy it to `wp_vol` and make a directory there.
- Add a link to the wp homepage to the new static page (redirects to the domain hsetyamu.42.fr).

#### Dockerfile
- Basically nothing has to be run, so the dockerfile (and the init script) just shares some responsibility to copy the static page files to a certain location in the wp_volume.

<details>
<summary>🗟Dockerfile (static page)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install nothing

#init script
COPY ./tools/staticp_init.sh /usr/local/bin/staticp_init.sh
RUN chmod +x /usr/local/bin/staticp_init.sh

#the static page
COPY ./contents/ /tmp/jumper/

ENTRYPOINT ["/usr/local/bin/staticp_init.sh"]
```
</details>

#### Script
- The init script for the static page does nothing more than just copying files.

<details>
<summary>🗟init script (static page)</summary>

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

echo -e "${CYA}Running staticp_init.sh${RES}"

#not sure if 5s is enough for all conts to be healthy if no helathchecks are performed
hoping_all_healthy()
{
	echo -e "${MAG}Hoping all containers are healthy (actually just sleeping here)${RES}"
	sleep 5s
}

#copy the prepared static page to the volume
copying_static()
{
	echo -e "${MAG}Deploying static page...${RES}"
	mkdir -p /var/www/html/jumper
	cp -r /tmp/jumper/. /var/www/html/jumper/
	echo -e "${GRE}Deploying static page...Done!${RES}"
}

hoping_all_healthy
copying_static

echo -e "${GRE}Static page copied.${RES}"
```
</details>

- The default wordpress theme is a block theme, so the following script is to create a link on the homepage to the newly created static page.
- This script is called by the makefile. Obviously the functionality can be delegated to wp_init.sh script, but i bumped with synchronization time between (re)mounting the wp_volume and checking the existence of the static page directory. So i leave it like this for now.
<details>
<summary>🗟creating link (static page)</summary>

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

#all this is called by the makefile
echo -e "${CYA}Running link_setup.sh${RES}"

#creating link for a block theme in wp
creating_link()
{
	echo -e "${MAG}Creating link...${RES}"
	docker exec wp_cont wp post create \
		--post_type=wp_navigation \
		--post_status=publish \
		--post_title="Main Navigation" \
		--post_content='<!-- wp:navigation-link {"label":"Mock Résumé","url":"https://hsetyamu.42.fr/jumper/"} /-->' \
		--allow-root --path=/var/www/html
	echo -e "${GRE}Creating link...Done!${RES}"
}

creating_link

echo -e "${GRE}New link is set up.${RES}"
```
</details>

#### Confs
- no confs here

#### Using static page
- Just click on the link in the homepage or go to `https://localhost/jumper` --> this link is made by the script that is run at the end of the makefile

### Redis cache
- redis is a caching server plugin for wordpress that is setup in its own container but the connection has to be established from the worpress side. 
- has a volume
- has to be connected to wordpress --> separately under bonus (`connect_redis()` in wp_init.sh)

#### Dockerfile
<details>
<summary>🗟Dockerfile (redis)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install redis
RUN apk update && apk add --no-cache\
	redis

#init script
COPY tools/redis_init.sh /usr/local/bin/redis_init.sh
RUN chmod +x /usr/local/bin/redis_init.sh

#create dir for redis data
RUN mkdir -p /data && chown redis:redis /data

#expose port (purely metadata)
#EXPOSE 6379

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/redis_init.sh"]
#CMD [ "redis-server", "--bind", "0.0.0.0", "--protected-mode", "no", "--dir", "/data" ]

```
</details>

#### Script
- the script is just to run the PID1.

<details>
<summary>🗟init script (redis)</summary>

```sh
#!/bin/sh
set -e

RED='\033[0;31m'
GRE='\033[0;32m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running redis_init.sh${RES}"
echo -e "${GRE}Redis setup complete!${RES}"

# Start redis
exec redis-server --bind 0.0.0.0 --protected-mode no --dir /data
#protected mode is no bcause redis is isolated on inception_net,
# not exposed to host, so authentication is not required

# exec "$@"
```
</details>

#### Confs
- no confs here

#### Using Redis
- Go to `https://localhost/wp-admin` and login.
- Go to the tab `plugins`, see that redis is enabled.

### Adminer
- Just one php file that is downloaded by wget. Additional installation of some php packages may or may not be necessary.
- Access and display the database (use the credentials in .env and secrets. server is mariadb).
- Add a location in nginx config to accomodate this --> this has to be loaded separately (see nginx)

#### Dockerfile
<details>
<summary>🗟Dockerfile (adminer)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install dependencies
RUN apk update && apk add --no-cache\
	php83 \
	php83-session \
	php83-mysqli \
	php83-pdo_mysql \
	php83-mbstring \
	php83-json

#get adminer
RUN wget -O /usr/share/adminer.php \
	"https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php" \
	&& chmod u=rw,g=r,o=r /usr/share/adminer.php

#init script
COPY tools/adminer_init.sh /usr/local/bin/adminer_init.sh
RUN chmod +x /usr/local/bin/adminer_init.sh

WORKDIR /usr/share

#expose port (purely metadata)
#EXPOSE 8080

#use the init script as entrypoint
#ENTRYPOINT ["/usr/local/bin/adminer_init.sh"]
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/usr/share", "adminer.php"]
```
</details>

#### Script
- the script is just to run the PID1.

<details>
<summary>🗟init script (adminer)</summary>

```sh
#!/bin/sh
set -e

RED='\033[0;31m'
GRE='\033[0;32m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running adminer_init.sh${RES}"
echo -e "${GRE}Adminer setup complete!${RES}"

# Start adminer
exec php -S 0.0.0.0:8080 -t /usr/share adminer.php
# -S specify addr:port, -t specify document root

# exec "$@"
```
</details>

#### Confs
- no confs here (its in nginx)

#### Using Adminer
- Go to `https://localhost/adminer`
- Use credentials for mdb in .env and secrets, network is `mariadb`

### FTP server
- Insecure because not through tls --> needs certs, but this one is generated via nginx.
- Credentials in .env and secrets.
- Port exposure through docker-compose
- Directory permission & ownership is a headache!!

#### Dockerfile
<details>
<summary>🗟Dockerfile (vsftpd)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install vsftpd
RUN apk add --no-cache \
	vsftpd \
	openssl

#init script
COPY tools/vsftpd_init.sh /usr/local/bin/vsftpd_init.sh
RUN chmod +x /usr/local/bin/vsftpd_init.sh

#config file
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

#create FTP user home directory
RUN mkdir -p /home/ftpuser

#expose ports
#21: Command port
#21000-21010: Passive mode data ports
#EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/vsftpd_init.sh"]
# CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]
```
</details>

#### Script
- FTP_USER in in the same group as www-data, so the directory is set to be writable by group.

<details>
<summary>🗟init script (vsftpd)</summary>

```sh
#!/bin/sh
set -e

RED='\033[0;31m'
GRE='\033[0;32m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running vsftpd_init.sh${RES}"

# Read credentials from secrets
FTP_USER="${FTP_USER}"
FTP_PASSWORD="$(cat /run/secrets/ftp_pw)"

# Create FTP user if doesn't exist
if ! id "$FTP_USER" >/dev/null 2>&1; then
	echo -e "${MAG}Creating FTP user: $FTP_USER${RES}"
	adduser -D -G www-data -h /home/$FTP_USER -s /bin/sh "$FTP_USER"
	echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
	echo -e "${GRE}FTP user created${RES}"
else
	echo -e "${GRE}FTP user already exists${RES}"
fi

# Add user to allowed list
echo "$FTP_USER" > /etc/vsftpd/user_list

# Set permissions
#chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
chmod ug=rwx,o=rx /home/$FTP_USER

echo -e "${GRE}FTP server setup complete!${RES}"

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

# exec "$@"
```
</details>

#### Confs

<details>
<summary>🗟Config (vsftpd)</summary>

```
#run in foreground
background=NO

#allow local users to login
local_enable=YES

#enable write commands
write_enable=YES

#chroot users to their home directory
chroot_local_user=YES
allow_writeable_chroot=YES

#passive mode configuration (?)
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
pasv_address=0.0.0.0

#disable anonymous FTP
anonymous_enable=NO

#security settings
seccomp_sandbox=NO
ssl_enable=NO

#logging
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log

#user list
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

#local umask (?)
local_umask=022

#maximum data transfer rate (0 = unlimited)
local_max_rate=0
```
</details>

#### Using ftp
```
#connect
lftp -u ftpuser,password ftp://localhost:21

#list files, change dirs
ls, cd

#download
lftp> get /local/file.txt

#upload
lftp> put /local/file.txt
```
- or just use filezilla

### Portainer
- Yes, it's Portainer. Monica is not available in alpine, Opentdd has problems with vnc, gramps web is too complicated to set up, hugo just cant work. Phew, so here it is, Portainer.

#### Dockerfile
<details>
<summary>🗟Dockerfile (portainer)</summary>

```docker
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install packages/dependencies
RUN apk add --no-cache \
	curl \
	ca-certificates

#get portainer
RUN curl -L https://github.com/portainer/portainer/releases/download/2.33.5/portainer-2.33.5-linux-amd64.tar.gz \
	-o /usr/local/bin/portainer.tar.gz && \
	tar -xzf /usr/local/bin/portainer.tar.gz -C /usr/local/bin/ && \
	rm -rf /usr/local/bin/portainer.tar.gz && \
	chmod +x /usr/local/bin/portainer/portainer

#create data directory
RUN mkdir -p /data

#init script
COPY tools/portainer_init.sh /usr/local/bin/portainer_init.sh
RUN chmod +x /usr/local/bin/portainer_init.sh

#expose port
#EXPOSE 9000 9443 8000

ENTRYPOINT ["/usr/local/bin/portainer_init.sh"]
```
</details>

#### Script
<details>
<summary>🗟init script (portainer)</summary>

```sh
#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

set -e

echo -e "${CYA}Running portainer_init.sh${RES}"

setup_portainer()
{
	echo -e "${MAG}Setting up Portainer...${RES}"
	mkdir -p /data
	chmod u=rwx,go= /data
	echo -e "${GRE}Setting up Portainer...Done!${RES}"
}

#start portainer with:
# - http on port 9000
# - https on port 9443 (optional)
# - edge agent on port 8000 (optional)
# - data stored in /data
# - no analytics
# - hide labels
start_portainer()
{
	echo -e "${MAG}Starting Portainer...${RES}"
	exec /usr/local/bin/portainer/portainer \
		--data /data \
		--bind :9000 \
		--bind-https :9443 \
		--no-analytics \
		--hide-label owner=inception
}

setup_portainer
start_portainer
```
</details>

#### Confs
<details>
<summary>🗟Config (portainer)</summary>
</details>

#### Using portainer
- open in `https://localhost:9443` or via nginx `https://localhost/portainer`
- default credentials because it has no persistence (no volume)
	- user: admin
	- password: YourSecurepassword123!
- then go to get started

## Evals
- comments on the blog post
- edits on the sample page
- make aware:
	- homepage has no links to static page __BEFORE__ bonus
	- wp-admin plugins has no redis __BEFORE__ bonus
	- empty location (desktop?) __BEFORE__ downloading something via ftp

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
https://pkgs.alpinelinux.org/packages


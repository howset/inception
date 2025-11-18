# Inception

## Content
- [Guides to read](#guides-to-read)
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
- [References](#references)

## Guides to read
- https://github.com/Vikingu-del/Inception-Guide (from start to end ?)
- https://github.com/Forstman1/inception-42
- https://github.com/vbachele/Inception
- https://github.com/Xperaz/inception-42
- https://medium.com/@imyzf/inception-3979046d90a0
- https://github.com/facetint/Inception
- https://github.com/cfareste/Inception
- https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker

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

## Docker containers
- The base image can basically be from anything, either from debian:bookworm or alpine:3.21.1 as long as the kernel is the same (linux), the difference is the size of the image using alpine ended up smaller than debian (~200 MB vs ~500 MB), and some adjustments also has to be made due to some differences between the systems (e.g. alpine has no bash by default).

- Useful but can be confusing commands:[^6]

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

### Mariadb
#### Dockerfile

- May not use a prebuilt image[^8].
- Since the init script that is used as the entrypoint was made during testing (using bash as default in the shebang), so bash has to be installed along with mariadb server & client.
- Although setting file permissions using RUN may seem to be unnecessarily adding layers, but its safer and easier to make sure that all runs nicely.

```docker
# Base image
FROM alpine:3.21.1

#install mdb
RUN apk update && apk add \
	mariadb \
	mariadb-client \
	bash

#init script
COPY tools/mdb_init.sh /usr/local/bin/mdb_init.sh
RUN chmod +x /usr/local/bin/mdb_init.sh

#mdb config
COPY conf/mdb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod u=rw,go=r /etc/mysql/mariadb.conf.d/50-server.cnf

#expose port (for WP connection)
EXPOSE 3306

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]
CMD ["mariadb"]
```
#### Entrypoint script
apply_secure_fixes() == mysql_secure_installation[^7]

```bash
#!/bin/bash

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

start_mdb_bg()
{
	mkdir -p /run/mysqld #-p avoids errors if it already exists
	#create database if not already done
	if [ ! -d /var/lib/mysql/mysql ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi
	chown -R mysql:mysql /run/mysqld /var/lib/mysql #set mysql user and group
	chmod u=rwx,g=,o= /run/mysqld #set permissions so only owner mysql can read/write/execute in dir to improve security.
	mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking=0 --bind-address=0.0.0.0 & #mdb server daemon in bg, specify user, datadir, ensure networking is enabled, & allow any connection
	sleep 5
}

#reproduce mysql_secure_installation noninteractively
apply_secure_fixes()
{
	mariadb -e "DELETE FROM mysql.user WHERE User='';" #remove anon users
	mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" #allow only localhost/root access
	mariadb -e "DROP DATABASE IF EXISTS test;" #remove default test db, unnecessary actually
	mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" #Remove privileges related to it
	mariadb -e "FLUSH PRIVILEGES;" #apply immediately
}

setup_db()
{
	local DATABASE_NAME=MDB_NAME666
	local DATABASE_USER_NAME=MDB_USER666
	local DATABASE_USER_PASSWORD=MDB_PASSWD666

	mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;" #create db
	mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';" #adds new user with password, allowing connection from any host ('%')
	mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';" #give full privilege to user
	mariadb -e "FLUSH PRIVILEGES;"
}

start_mdb_bg
apply_secure_fixes
setup_db

# stop temporary background server
if pgrep mariadbd >/dev/null 2>&1; then #check if mdb is running
	mysqladmin --user=root shutdown 2>/dev/null || pkill mariadbd #stop nicely or kill it
	while pgrep mariadbd >/dev/null 2>&1; do sleep 0.1; done #waits until process fully exits
fi

# Start MariaDB server in the foreground (PID 1)
exec mariadbd --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
```

#### Configs
### Nginx
#### Dockerfile

#### Entrypoint script

#### Configs
### Wordpress
#### Dockerfile

#### Entrypoint script

#### Configs

## References
[^1]: https://itsfoss.com/alpine-linux-virtualbox/
[^2]: https://krython.com/post/installing-alpine-linux-in-virtualbox/
[^3]: https://wiki.alpinelinux.org/wiki/Kernels
[^4]: https://wiki.alpinelinux.org/wiki/Xfce
[^5]: https://wiki.alpinelinux.org/wiki/VirtualBox_shared_folders
[^6]: https://dockerlabs.collabnix.com/docker/cheatsheet/
[^7]: https://dev.mysql.com/doc/refman/8.4/en/mysql-secure-installation.html
[^8]: https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/creating-a-custom-container-image

## Plan

1. Create a Nginx container
- Similar structure: Dockerfile + config files + init script
- Expose port 443 (HTTPS) and 80 (HTTP)
- Serve static files or reverse proxy

2. Create a WordPress container
- Install PHP-FPM
- Install WordPress core files
- Configure to connect to MariaDB using env vars
- Set up proper file permissions

3. Use docker-compose to orchestrate all services
- Define all three services (MariaDB, Nginx, WordPress)
- Set up networking between containers
- Define volumes for data persistence
- Pass environment variables to each service

4. Add volume management
- Persistent storage for databases (/var/lib/mysql)
- Persistent storage for WordPress files
- Persistent storage for Nginx configs

5. Test the full stack
- Verify all containers communicate
- Test WordPress installation and functionality
- Check data persists after container restart

Priority: Start with docker-compose to tie everything together, then build/test the WordPress container.
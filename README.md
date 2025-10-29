# Inception

## Guides to read
- https://github.com/Vikingu-del/Inception-Guide (from start to end ?)
- https://github.com/Forstman1/inception-42
- https://github.com/vbachele/Inception
- https://github.com/Xperaz/inception-42
- https://medium.com/@imyzf/inception-3979046d90a0

## VM setup & OS installation
Reqs:
1. virtualbox
2. alpine linux, penultimate stable in https://alpinelinux.org/downloads/. (x86_64 for cluster comps)

### Preparation
- open virtualbox & press new
- specify folder in `sgoinfre`
- specify:
```
memory 1-3GB
HD 20-30GB
processors ?
```
- go to settings, storage
- put the iso in the optical drive

### Install OS
- press start in virtual box
- initial login with `root`
- set keyboard layout & variant as `us`
- enter system hostname as `[username].42.fr`
- just press enter to everything (default) up to manual network configuration to which answer `no`
- setup root password
- set timezone
- set proxy, network time protocol and apk mirror again to default (just press enter)
- setup username as [username] & password (the same with root)
- ssh key as none & choose openssh
- use `sda` disk as `sys`. Erase and continue
- remove the iso from virtualbox & type `$> reboot`

### OS setup, essential installations, & configs
#### Install sudo
- to install sudo, make community repo available. Edit the list & uncomment community repo
```sh
$> vi /etc/apk/repositories
```
- change to root 
```sh
$> su -
```
- install sudo
```sh
$> apk update
$> apk add sudo
```
- to make it usable, go `visudo`, uncomment the root line & %sudo
- create group & add user
```sh
$> addgroup sudo
$> adduser [username] sudo
$> getent group sudo #check
```
- then reboot (!!!)
```sh
$> reboot
```

#### Install nano & ssh config
- to install nano like many other happy people
```sh
$> sudo apk update #just good practice 4 any distro
$> sudo apk add nano
```
- configure ssh
```sh
$> sudo nano /etc/ssh/sshd_config
```
- uncomment port 22 and change it to 4242 & uncomment PermitRootLogin then set to no
- similarly,
```sh
$> sudo nano /etc/ssh/ssh_config/
```
- uncomment port 22 & change it to 4242
- restart ssh service & check
```sh
$> sudo rc-service sshd restart
$> netstat -tuln | grep 4242
```
- in virtualbox, go to `settings` -> `network` -> `port forwarding`
- set host as 4243 (berlin cluster), guest as 4242
- test from cluster terminal
```sh
$> ssh localhost -p 4243 #or ssh 127.0.0.1 -p 4242
```

#### Install make
- make may not be available in minimal distro
```sh
$> sudo apk update #just good practice 4 any distro
$> sudo apk add make
```

#### Install docker, docker compose, & docker-cli-compose
- get docker
```sh
$> sudo apk update #just good practice 4 any distro
$> sudo apk add docker docker-compose
```
- update
```sh
$> sudo apk add --update docker openrc
```
- config to start the daemon at boot
```sh
$> sudo rc-update add docker boot # or rc-update add docker default
```
- check status & start if necessary
```sh
$> service docker status  # check status
$> sudo service docker start
```
- add user to docker group (necessary to connect to the daemon through the sockets)
```sh
$> sudo addgroup [username] docker
```
- now install the command line interface
```sh
$> sudo apk add docker-cli-compose
```

#### Setup a shared folder
- Create a mount point and install libraries 
```sh
$> mkdir -p /mnt/shared
$>apk add virtualbox-guest-additions linux-virt
```
- Reboot (setup shared folder in virtualbox gui if required as well)
- Then mount the folder 
```sh
modprobe -a vboxsf 
mount -t vboxsf vbox_shared /mnt/shared
```
- Change `vbox_shared` to whatever name specified in the virtualbox gui.
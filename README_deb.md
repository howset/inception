# Inception

## Guides to read
- https://github.com/Vikingu-del/Inception-Guide (from start to end ?)
- https://github.com/Forstman1/inception-42
- https://github.com/vbachele/Inception
- https://github.com/Xperaz/inception-42
- https://medium.com/@imyzf/inception-3979046d90a0
- https://askubuntu.com/questions/456400/why-cant-i-access-a-shared-folder-from-within-my-virtualbox-machine
- https://www.reddit.com/r/virtualbox/comments/11mekqg/shared_folders_to_debian_vm/

## VM setup & OS installation
Reqs:
1. virtualbox
2. debian, penultimate stable in https://cdimage.debian.org/mirror/cdimage/archive/

### Preparation
- open virtualbox & press new
- specify folder in `sgoinfre`
- specify:
```
memory 4096 MB
HD 20 GB
processors 5
```
- go to settings, storage
- put the iso in the optical drive

### Install OS
- Follow graphical install
- Use either gnome/xfce. Include debian DE.

### OS setup
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
- Install Guest Additions in vm
	- Install required packages `sudo apt update && sudo apt install build-essential dkms linux-headers-$(uname -r)`
	- On the vm window go to Devices and from the drop-down menu choose "Insert Guest Additions CD Image".
	- On vm:
	```bash
	$> sudo mkdir -p /mnt/guestadditions
	$> sudo mount /dev/cdrom /mnt/guestadditions #ignore warning
	$> cd /mnt/guestadditions
	$> sudo sh ./VBoxLinuxAdditions.run --nox11 #run script
	```
	- reboot vm `sudo shutdown -r now`
	- verify installation by checking the loaded kernel modules `lsmod | grep vboxguest`
- Make a dir to be shared in host machine
- Set it up in virtualbox to be shared (`Settings --> Shared Folders`)
	- Specify folder path and folder name
	- Check automount
- In vm:
```bash
$> mkdir ~/new
$> sudo mount -t vboxsf New ~/new #New is the folder name in host, ~/new is shared folder in vm
```
- To make it permanent, edit /etc/fstab and add the line `New /home/user/new vboxsf defaults 0 0`
- The guest additions can be removed from drive once the shared folder has been tested to work properly.


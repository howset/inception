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
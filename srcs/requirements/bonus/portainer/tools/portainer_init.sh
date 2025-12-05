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
		 --base-url /portainer \
		--no-analytics \
		--hide-label owner=inception
}

setup_portainer
start_portainer
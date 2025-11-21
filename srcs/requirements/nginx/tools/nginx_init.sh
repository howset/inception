#!/bin/bash

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
generate_ss_ssl()
{
	if [ ! -f /etc/nginx/ssl/server.crt ]; then
		openssl req -x509 \
			-newkey rsa:4096 \
			-keyout /etc/nginx/ssl/server.key \
			-out /etc/nginx/ssl/server.crt \
			-days 365 \
			-nodes \
			-subj "/C=DE/ST=Berlin/L=Berlin/O=42/CN=localhost"
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

create_dirs
generate_ss_ssl
set_permissions

echo -e "${GRE}nginx setup complete!${RES}"

# Start Nginx in the foreground/PID 1 (daemon off)
exec nginx -g "daemon off;"
# exec "$@"
#!/bin/bash

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

#create directories
create_dirs()
{
	mkdir -p /etc/nginx/ssl #to store SSL/TLS certificates and keys
	mkdir -p /run/nginx #reate nginx run directory if it doesn't exist
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
	chmod u=rw,go= /etc/nginx/ssl/server.key
	chmod u=rw,g=r,o=r /etc/nginx/ssl/server.crt
}

create_dirs
generate_ss_ssl
set_permissions

# Start Nginx in the foreground/PID 1 (daemon off)
exec "$@"
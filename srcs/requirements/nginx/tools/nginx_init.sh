#!/bin/bash

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

#create directory to store SSL/TLS certificates and keys
mkdir -p /etc/nginx/ssl

#generate self-signed SSL certificate if it doesn't exist
if [ ! -f /etc/nginx/ssl/server.crt ]; then
	openssl req -x509 -newkey rsa:4096 \
		-keyout /etc/nginx/ssl/server.key \
		-out /etc/nginx/ssl/server.crt \
		-days 365 -nodes \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/CN=localhost"
fi

# Set proper permissions for SSL files
chmod u=rw,go= /etc/nginx/ssl/server.key
chmod u=rw,g=r,o=r /etc/nginx/ssl/server.crt

# Create nginx run directory if it doesn't exist
mkdir -p /run/nginx

# Start Nginx in the foreground (PID 1)
exec nginx -g "daemon off;" "$@"
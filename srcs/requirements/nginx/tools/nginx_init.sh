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

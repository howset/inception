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

echo -e "${CYA}Running wp_init.sh${RES}"

wait_mdb()
{
	#wait for mdb to be ready
	echo -e "${MAG}Waiting for MariaDB...${RES}"
	while ! nc -z mariadb 3306; do
		sleep 1
	done
	echo -e "${GRE}MariaDB is ready!${RES}"
}

#deal with wordpress
#change memory limit
change_limit()
{
	sed -i 's/^memory_limit = .*/memory_limit = 256M/' /etc/php83/php.ini
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
	if [ ! -f /var/www/html/wp-config.php ]; then
		echo -e "${MAG}Creating wp-config.php...${RES}"
		wp config create --allow-root \
			--path=/var/www/html/ \
			--dbname="MDB_NAME666" \
			--dbuser="MDB_USER666" \
			--dbpass="MDB_PASSWD666" \
			--dbhost="mariadb"
		echo -e "${GRE}Creating wp-config.php...Done!${RES}"
	else
		echo -e "${YEL}wp-config.php already exists${RES}"
	fi
}

#install wp
wp_core_install()
{
	if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
		echo -e "${MAG}Installing WordPress...${RES}"
		wp core install --allow-root \
			--path=/var/www/html/ \
			--url="hsetyamu.42.fr" \
			--title="Inception" \
			--admin_user="WP_ADMIN_USER" \
			--admin_password="WP_ADMIN_PASSWORD" \
			--admin_email="wp@goo.co" \
			--skip-email
		echo -e "${GRE}Installing WordPress...Done!${RES}"
	else
		echo -e "${YEL}WordPress already installed${RES}"
	fi
}

#set permissions
set_permissions()
{
	echo -e "${MAG}Setting permissions${RES}"
	chown -R nobody:nobody /var/www/html
	chmod -R u+rwx,go+rx /var/www/html
	echo -e "${GRE}Setting permissions...Done!${RES}"
}

wait_mdb
change_limit
wp_core_download
wp_config_create
wp_core_install
set_permissions

echo -e "${GRE}WordPress setup complete!${RES}"

#start PHP-FPM in foreground
exec php-fpm83 -F
# exec "$@"
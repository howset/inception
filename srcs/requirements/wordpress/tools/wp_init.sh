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

echo -e "${CYA}Running wp_init.sh${RES}"

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
	local DB_USER_PW=$(cat /run/secrets/DB_USER_PW)
	if [ ! -f /var/www/html/wp-config.php ]; then
		echo -e "${MAG}Creating wp-config.php...${RES}"
		wp config create --allow-root \
			--path=/var/www/html/ \
			--dbname="${DB_NAME}" \
			--dbuser="${DB_USER_NAME}" \
			--dbpass="$DB_USER_PW" \
			--dbhost="${DB_HOST}"
		echo -e "${GRE}Creating wp-config.php...Done!${RES}"
	else
		echo -e "${YEL}wp-config.php already exists${RES}"
	fi
}

#install wp
wp_core_install()
{
	local WP_ADM_PW=$(cat /run/secrets/WP_ADM_PW)
	if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
		echo -e "${MAG}Installing WordPress...${RES}"
		wp core install --allow-root \
			--path=/var/www/html/ \
			--url="hsetyamu.42.fr" \
			--title="Inception" \
			--admin_user="${WP_ADM_USER}" \
			--admin_password="$WP_ADM_PW" \
			--admin_email="${WP_ADM_EMAIL}" \
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

change_limit
wp_core_download
wp_config_create
wp_core_install
set_permissions

echo -e "${GRE}WordPress setup complete!${RES}"

#start PHP-FPM in foreground
exec php-fpm83 -F
# exec "$@"
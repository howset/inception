#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running staticp_init.sh${RES}"

#not sure if 5s is enough for all conts to be healthy if no helathchecks are performed
hoping_all_healthy()
{
	echo -e "${MAG}Hoping all containers are healthy (actually just sleeping here)${RES}"
	sleep 5s
}

#copy the prepared static page to the volume
deploying_static()
{
	echo -e "${MAG}Deploying static page...${RES}"
	docker exec nginx_cont sh -c 'mkdir -p /var/www/html/jumper' >/dev/null
	docker cp bonus/static_page/. nginx_cont:/var/www/html/jumper/
	echo -e "${GRE}Deploying static page...Done!${RES}"
}

setup_theme_links()
{
	echo -e "${MAG}Setting up new theme and create link...${RES}"
	#install a non-block theme
	docker exec wp_cont wp theme install twentytwentyone --activate --allow-root --path=/var/www/html >/dev/null
	#create link 
	docker exec wp_cont wp menu create "Main" --allow-root --path=/var/www/html >/dev/null
	docker exec wp_cont wp menu location list --allow-root --path=/var/www/html >/dev/null
	docker exec wp_cont wp menu location assign Main primary --allow-root --path=/var/www/html >/dev/null
	docker exec wp_cont wp menu item add-custom "Main" "Mock Résumé" "https://localhost/jumper/" --allow-root --path=/var/www/html >/dev/null
	#update so https works
	docker exec wp_cont wp option update home https://localhost --allow-root --path=/var/www/html >/dev/null
	docker exec wp_cont wp option update siteurl https://localhost --allow-root --path=/var/www/html >/dev/null
	echo -e "${GRE}Setting up new theme and create link...Done!${RES}"
}

hoping_all_healthy
deploying_static
setup_theme_links

echo -e "${GRE}Static page available at: https://localhost/jumper/${RES}"
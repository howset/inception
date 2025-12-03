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

#all this is called by the makefile
echo -e "${CYA}Running link_setup.sh${RES}"

#creating link for a block theme in wp
creating_link()
{
	echo -e "${MAG}Creating link...${RES}"
	docker exec wp_cont wp post create \
		--post_type=wp_navigation \
		--post_status=publish \
		--post_title="Main Navigation" \
		--post_content='<!-- wp:navigation-link {"label":"Mock Résumé","url":"https://hsetyamu.42.fr/jumper/"} /-->' \
		--allow-root --path=/var/www/html
	echo -e "${GRE}Creating link...Done!${RES}"
}

creating_link

echo -e "${GRE}New link is set up.${RES}"

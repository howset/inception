#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

set -e

echo -e "${CYA}Running link_setup.sh${RES}"

get_nav_id()
{
	docker exec wp_cont wp post list \
		--post_type=wp_navigation \
		--format=ids \
		--allow-root \
		--path=/var/www/html | awk '{print $1}'
}

creating_link()
{
	echo -e "${MAG}Creating navigation links...${RES}"

	NAV_ID=$(get_nav_id)

	#navigation content with all links
	NAV_CONTENT=$(cat <<'EOF'
<!-- wp:navigation-link {"label":"Mock Résumé","url":"https://hsetyamu.42.fr/jumper/"} /-->
<!-- wp:navigation-link {"label":"Adminer","url":"https://adminer.hsetyamu.42.fr/"} /-->
<!-- wp:navigation-link {"label":"Portainer","url":"https://portainer.hsetyamu.42.fr/"} /-->
EOF
	)

	#remove newlines (wp need it as one line)
	NAV_CONTENT=$(echo "$NAV_CONTENT" | tr -d '\n')

	if [ -n "$NAV_ID" ]; then
		echo -e "${YEL}Updating existing navigation (ID: $NAV_ID)${RES}"
		docker exec wp_cont wp post update "$NAV_ID" \
			--post_content="$NAV_CONTENT" \
			--allow-root \
			--path=/var/www/html
	else
		echo -e "${YEL}Creating new navigation with all links${RES}"
		docker exec wp_cont wp post create \
			--post_type=wp_navigation \
			--post_status=publish \
			--post_title="Main Navigation" \
			--post_content="$NAV_CONTENT" \
			--allow-root \
			--path=/var/www/html
	fi
	
	echo -e "${GRE}Creating navigation links...Done!${RES}"
}

creating_link

echo -e "${GRE}Navigation links are set up.${RES}"
##------------------------------------------------------------------##
#Text colours
RED:=\033[0;31m
GRE:=\033[0;32m
YEL:=\033[1;33m
BLU:=\033[0;34m
MAG:=\033[0;35m
CYA:=\033[0;36m
RES:=\033[0m

#Variables
#Specify docker compose
DOCKER_COMPOSE := docker-compose -f ./srcs/docker-compose.yml
# Containers
# WP_CONT := wp_cont
# NGINX_CONT := nginx_cont
# # Where to mount the static page under WP's docroot
# STATIC_PATH := /var/www/html/jumper
# STATIC_SRC := bonus/static_page

##------------------------------------------------------------------##
#Targets

all: up

#Build services
build:
	$(DOCKER_COMPOSE) build

#Create (build) and start
up: build
	$(DOCKER_COMPOSE) up -d

ps:
	$(DOCKER_COMPOSE) ps

logs:
	$(DOCKER_COMPOSE) logs

logs-bonus:
	$(DOCKER_COMPOSE) --profile bonus logs

#Stop and remove cintainers (and network)
down:
	$(DOCKER_COMPOSE) down

#Down and remove images
clean: 
	$(DOCKER_COMPOSE) --profile bonus down --rmi all --remove-orphans

#Full clean: remove containers, networks, volumes, and images
fclean:
	$(DOCKER_COMPOSE) --profile bonus down --rmi all -v --remove-orphans

re: fclean all

# List Docker resources on the host (images, containers, volumes, networks)
list:
	@echo -e "${BLU}== Images ==${RES}" && docker images
	@echo -e "${RED}== Containers ==${RES}" && docker ps -a
	@echo -e "${GRE}== Volumes ==${RES}" && docker volume ls
	@echo -e "${YEL}== Networks ==${RES}" && docker network ls

bonus: all
	$(DOCKER_COMPOSE) --profile bonus up -d --build staticpage
	./bonus/static_page/tools/link_setup.sh
	$(DOCKER_COMPOSE) --profile bonus up -d --build redis
	$(DOCKER_COMPOSE) up -d --force-recreate wordpress

##------------------------------------------------------------------##
.PHONY: all build up ps logs down clean fclean re list bonus
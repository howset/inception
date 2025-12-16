##------------------------------------------------------------------##
#Text colours
RED:=\033[0;31m
GRE:=\033[0;32m
YEL:=\033[1;33m
BLU:=\033[0;34m
MAG:=\033[0;35m
CYA:=\033[0;36m
RES:=\033[0m

#Specify docker compose
DOCKER_COMPOSE := docker-compose -f ./srcs/docker-compose.yml

##------------------------------------------------------------------##
#Targets

all: build up

#Build services
build:
	sudo mkdir -pv /home/hsetyamu/data/mdb_data/
	sudo mkdir -pv /home/hsetyamu/data/wp_data/
	$(DOCKER_COMPOSE) build

#Create (build) and start
up:
	$(DOCKER_COMPOSE) up -d
# 	$(DOCKER_COMPOSE) up -d --no-deps

logs:
	$(DOCKER_COMPOSE) logs

logs-bonus:
	$(DOCKER_COMPOSE) --profile bonus logs

#Stop and remove cintainers (and network)
down:
	$(DOCKER_COMPOSE) down

#stop containers without removing
stop:
	$(DOCKER_COMPOSE) stop

#start stopped containers (without rebuilding)
start:
	$(DOCKER_COMPOSE) start

#restart container
restart:
	$(DOCKER_COMPOSE) restart

#Down and remove images
clean: 
	$(DOCKER_COMPOSE) --profile bonus down --rmi all --remove-orphans

#Full clean: remove containers, networks, volumes, and images
fclean:
	$(DOCKER_COMPOSE) --profile bonus down --rmi all -v --remove-orphans
	docker builder prune -f
	sudo rm -rf /home/hsetyamu/data/

re: fclean all

#List Docker resources on the host (images, containers, volumes, networks)
list:
	@echo -e "${BLU}== Images ==${RES}" && docker images
	@echo -e "${RED}== Containers ==${RES}" && docker ps -a
	@echo -e "${GRE}== Volumes ==${RES}" && docker volume ls
	@echo -e "${YEL}== Networks ==${RES}" && docker network ls
	@echo -e "${MAG}== Container PID 1 ==${RES}"
	@docker ps --format "{{.Names}}" | while read container; do \
		cmd=$$(docker exec $$container cat /proc/1/cmdline 2>/dev/null | tr '\0' ' ' || echo "N/A"); \
		echo -e "$$container:\t$$cmd"; \
	done

bonus: all
#	static page
	$(DOCKER_COMPOSE) --profile bonus up -d --build staticpage
#	redis
	sudo mkdir -pv /home/hsetyamu/data/redis_data/
	$(DOCKER_COMPOSE) --profile bonus up -d --build redis
#	adminer
	$(DOCKER_COMPOSE) --profile bonus up -d --build adminer
#	vsftpd
	$(DOCKER_COMPOSE) --profile bonus up -d --build vsftpd
# 	portainer
	$(DOCKER_COMPOSE) --profile bonus up -d --build portainer
# 	finishing up
	$(DOCKER_COMPOSE) up -d --force-recreate --no-deps wordpress
	$(DOCKER_COMPOSE) up -d --force-recreate --no-deps nginx
	./srcs/requirements/bonus/static_page/tools/link_setup.sh

##------------------------------------------------------------------##
.PHONY: all build up logs down stop start restart clean fclean re list bonus
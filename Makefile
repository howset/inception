##------------------------------------------------------------------##
# Variables.
DOCKER_COMPOSE := docker-compose -f ./srcs/docker-compose.yml

MDB_IMAGE = mdb:inception
MDB_CONTAINER = mdb_cont
MDB_DOCKERFILE = srcs/requirements/mariadb
MDB_VOLUME = srcs_mdb_data

NGINX_IMAGE = nginx:inception
NGINX_CONTAINER = nginx_cont
NGINX_DOCKERFILE = srcs/requirements/nginx

WP_IMAGE = wp:inception
WP_CONTAINER = wp_cont
WP_DOCKERFILE = srcs/requirements/wordpress
WP_VOLUME = srcs_wp_data

## Text colors
GRE = \033[0;32m
RED = \033[0;31m
RES = \033[0m

##------------------------------------------------------------------##
# Build rules

# Using docker-compose (recommended)
all-compose: compose-build compose-up

##------------------------------------------------------------------##
# Docker Compose targets
# Build images with docker-compose
compose-build:
	@echo -e "$(GRE)Building images with docker-compose...$(RES)"
	$(DOCKER_COMPOSE) build
	@echo -e "$(GRE)Build complete!$(RES)"

# Start services with docker-compose
compose-up:
	@echo -e "$(GRE)Starting services with docker-compose...$(RES)"
	$(DOCKER_COMPOSE) up -d
	@echo -e "$(GRE)Services started!$(RES)"

# Stop services with docker-compose
compose-stop:
	@echo -e "$(RED)Stopping services...$(RES)"
	$(DOCKER_COMPOSE) stop
	@echo -e "$(GRE)Services stopped!$(RES)"

# Remove containers and networks with docker-compose
compose-down:
	@echo -e "$(RED)Removing containers and networks...$(RES)"
	$(DOCKER_COMPOSE) down
	@echo -e "$(GRE)Containers removed!$(RES)"

# Remove everything including volumes with docker-compose
compose-clean:
	@echo -e "$(RED)Removing all services, volumes, and networks...$(RES)"
	$(DOCKER_COMPOSE) down -v
	@echo -e "$(GRE)Full clean complete!$(RES)"

# View logs from docker-compose
compose-logs:
	$(DOCKER_COMPOSE) logs -f

##------------------------------------------------------------------##
# Individual Docker Commands (legacy)
# Run MariaDB container
run-mdb:
	@echo -e "$(GRE)Starting MariaDB container...$(RES)"
	docker run -d \
		--name $(MDB_CONTAINER) \
		-p 3306:3306 \
		-v $(MDB_VOLUME):/var/lib/mysql \
		$(MDB_IMAGE)
	@echo -e "$(GRE)MariaDB container started!$(RES)"

# Run Nginx container
run-nginx:
	@echo -e "$(GRE)Starting Nginx container...$(RES)"
	docker run -d \
		--name $(NGINX_CONTAINER) \
		-p 80:80 \
		-p 443:443 \
		$(NGINX_IMAGE)
	@echo -e "$(GRE)Nginx container started!$(RES)"

# Run WordPress container
run-wordpress:
	@echo -e "$(GRE)Starting WordPress container...$(RES)"
	docker run -d \
		--name $(WORDPRESS_CONTAINER) \
		-p 9000:9000 \
		$(WORDPRESS_IMAGE)
	@echo -e "$(GRE)WordPress container started!$(RES)"

# Run all containers
run: run-mdb run-nginx run-wordpress

##------------------------------------------------------------------##
# Stop and remove all containers
clean:
	@echo -e "$(RED)Stopping and removing containers...$(RES)"
	-docker stop $(MDB_CONTAINER) 2>/dev/null || true
	-docker rm $(MDB_CONTAINER) 2>/dev/null || true
	-docker stop $(NGINX_CONTAINER) 2>/dev/null || true
	-docker rm $(NGINX_CONTAINER) 2>/dev/null || true
	-docker stop $(WORDPRESS_CONTAINER) 2>/dev/null || true
	-docker rm $(WORDPRESS_CONTAINER) 2>/dev/null || true
	@echo -e "$(GRE)Containers cleaned!$(RES)"

# Remove everything including images and volumes
fclean: compose-clean
	@echo -e "$(RED)Removing images and volumes...$(RES)"
	-docker rmi $(MDB_IMAGE) 2>/dev/null || true
	-docker rmi $(NGINX_IMAGE) 2>/dev/null || true
	-docker rmi $(WP_IMAGE) 2>/dev/null || true
	-docker volume rm $(MDB_VOLUME) 2>/dev/null || true
	-docker volume rm $(WP_VOLUME) 2>/dev/null || true
	-docker system prune -af --volumes 2>/dev/null || true
	@echo -e "$(GRE)Full clean complete!$(RES)"

# Rebuild everything
re:	fclean all
re-compose:	fclean all-compose

# Execute bash in MariaDB container
exec-mdb:
	docker exec -it $(MDB_CONTAINER) /bin/bash

# Execute bash in Nginx container
exec-nginx:
	docker exec -it $(NGINX_CONTAINER) /bin/bash

# Execute bash in WordPress container
exec-wordpress:
	docker exec -it $(WORDPRESS_CONTAINER) /bin/bash

##------------------------------------------------------------------##
#.PHONY
.PHONY: all all-compose build build-mdb build-nginx build-wordpress run run-mdb run-nginx run-wordpress stop stop-mdb stop-nginx stop-wordpress clean fclean re logs-mdb logs-nginx logs-wordpress exec-mdb exec-nginx exec-wordpress compose-build compose-up compose-stop compose-down compose-clean compose-logs compose-logs-mdb compose-logs-nginx compose-exec-mdb compose-exec-nginx compose-exec-wordpress
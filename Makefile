##------------------------------------------------------------------##
# Variables.
MDB_IMAGE = mdb
MDB_CONTAINER = mdb_container
MDB_DOCKERFILE = srcs/requirements/mariadb
MDB_VOLUME = mdb_data

NGINX_IMAGE = nginx
NGINX_CONTAINER = nginx_container
NGINX_DOCKERFILE = srcs/requirements/nginx

## Text colors
GRE = \033[0;32m
RED = \033[0;31m
RES = \033[0m

##------------------------------------------------------------------##
# Build rules

# Using docker-compose (recommended)
all-compose: compose-build compose-up

# Using individual docker commands (legacy)
all: build-mdb build-nginx run-mdb run-nginx

##------------------------------------------------------------------##
# Docker Compose targets

# Build images with docker-compose
compose-build:
	@echo -e "$(GRE)Building images with docker-compose...$(RES)"
	docker-compose build
	@echo -e "$(GRE)Build complete!$(RES)"

# Start services with docker-compose
compose-up:
	@echo -e "$(GRE)Starting services with docker-compose...$(RES)"
	docker-compose up -d
	@echo -e "$(GRE)Services started!$(RES)"

# Stop services with docker-compose
compose-stop:
	@echo -e "$(RED)Stopping services...$(RES)"
	docker-compose stop
	@echo -e "$(GRE)Services stopped!$(RES)"

# Remove containers and networks with docker-compose
compose-down:
	@echo -e "$(RED)Removing containers and networks...$(RES)"
	docker-compose down
	@echo -e "$(GRE)Containers removed!$(RES)"

# Remove everything including volumes with docker-compose
compose-clean:
	@echo -e "$(RED)Removing all services, volumes, and networks...$(RES)"
	docker-compose down -v
	@echo -e "$(GRE)Full clean complete!$(RES)"

# View logs from docker-compose
compose-logs:
	docker-compose logs -f

# View MariaDB logs from docker-compose
compose-logs-mdb:
	docker-compose logs -f mariadb

# View Nginx logs from docker-compose
compose-logs-nginx:
	docker-compose logs -f nginx

# Execute bash in MariaDB container via docker-compose
compose-exec-mdb:
	docker-compose exec mariadb /bin/bash

# Execute bash in Nginx container via docker-compose
compose-exec-nginx:
	docker-compose exec nginx /bin/bash

##------------------------------------------------------------------##
# Individual Docker Commands (legacy)

# Build MariaDB image
build-mdb:
	@echo -e "$(GRE)Building MariaDB image...$(RES)"
	docker build -t $(MDB_IMAGE) $(MDB_DOCKERFILE)
	@echo -e "$(GRE)MariaDB build complete!$(RES)"

# Build Nginx image
build-nginx:
	@echo -e "$(GRE)Building Nginx image...$(RES)"
	docker build -t $(NGINX_IMAGE) $(NGINX_DOCKERFILE)
	@echo -e "$(GRE)Nginx build complete!$(RES)"

# Build all images
build: build-mdb build-nginx

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

# Run all containers
run: run-mdb run-nginx

# Stop MariaDB container
stop-mdb:
	@echo -e "$(RED)Stopping MariaDB container...$(RES)"
	-docker stop $(MDB_CONTAINER) 2>/dev/null || true
	@echo -e "$(GRE)MariaDB container stopped!$(RES)"

# Stop Nginx container
stop-nginx:
	@echo -e "$(RED)Stopping Nginx container...$(RES)"
	-docker stop $(NGINX_CONTAINER) 2>/dev/null || true
	@echo -e "$(GRE)Nginx container stopped!$(RES)"

# Stop all containers
stop: stop-mdb stop-nginx

# Stop and remove all containers
clean:
	@echo -e "$(RED)Stopping and removing containers...$(RES)"
	-docker stop $(MDB_CONTAINER) 2>/dev/null || true
	-docker rm $(MDB_CONTAINER) 2>/dev/null || true
	-docker stop $(NGINX_CONTAINER) 2>/dev/null || true
	-docker rm $(NGINX_CONTAINER) 2>/dev/null || true
	@echo -e "$(GRE)Containers cleaned!$(RES)"

# Remove everything including images and volumes
fclean: clean
	@echo -e "$(RED)Removing images and volumes...$(RES)"
	-docker rmi $(MDB_IMAGE) 2>/dev/null || true
	-docker rmi $(NGINX_IMAGE) 2>/dev/null || true
	-docker volume rm $(MDB_VOLUME) 2>/dev/null || true
	@echo -e "$(GRE)Full clean complete!$(RES)"

# Rebuild everything
re: fclean all

# Show MariaDB logs
logs-mdb:
	docker logs $(MDB_CONTAINER)

# Show Nginx logs
logs-nginx:
	docker logs $(NGINX_CONTAINER)

# Execute bash in MariaDB container
exec-mdb:
	docker exec -it $(MDB_CONTAINER) /bin/bash

# Execute bash in Nginx container
exec-nginx:
	docker exec -it $(NGINX_CONTAINER) /bin/bash

##------------------------------------------------------------------##
#.PHONY
.PHONY: all all-compose build build-mdb build-nginx run run-mdb run-nginx stop stop-mdb stop-nginx clean fclean re logs-mdb logs-nginx exec-mdb exec-nginx compose-build compose-up compose-stop compose-down compose-clean compose-logs compose-logs-mdb compose-logs-nginx compose-exec-mdb compose-exec-nginx
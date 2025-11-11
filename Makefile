##------------------------------------------------------------------##
# Variables.
IMAGE_NAME = mdb
CONTAINER_NAME = mdb_container
DOCKERFILE_PATH = srcs/requirements/mariadb
VOLUME_NAME = mdb_data

## Text colors
GRE = \033[0;32m
RED = \033[0;31m
RES = \033[0m

##------------------------------------------------------------------##
# Build rules
all: build run

# Build the Docker image
build:
	@echo -e "$(GRE)Building MariaDB image...$(RES)"
	docker build -t $(IMAGE_NAME) $(DOCKERFILE_PATH)
	@echo -e "$(GRE)Build complete!$(RES)"

# Run the container
run:
	@echo -e "$(GRE)Starting MariaDB container...$(RES)"
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 3306:3306 \
		-v $(VOLUME_NAME):/var/lib/mysql \
		$(IMAGE_NAME)
	@echo -e "$(GRE)Container started!$(RES)"

# Stop and remove the container
clean:
	@echo -e "$(RED)Stopping and removing container...$(RES)"
	-docker stop $(CONTAINER_NAME) 2>/dev/null || true
	-docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo -e "$(GRE)Container cleaned!$(RES)"

# Remove everything including image and volume
fclean: clean
	@echo -e "$(RED)Removing image and volume...$(RES)"
	-docker rmi $(IMAGE_NAME) 2>/dev/null || true
	-docker volume rm $(VOLUME_NAME) 2>/dev/null || true
	@echo -e "$(GRE)Full clean complete!$(RES)"

# Rebuild everything
re: fclean all

# Show container logs
logs:
	docker logs -f $(CONTAINER_NAME)

# Execute bash in the running container
exec:
	docker exec -it $(CONTAINER_NAME) /bin/bash

##------------------------------------------------------------------##
#.PHONY
.PHONY: all build run clean fclean re logs exec
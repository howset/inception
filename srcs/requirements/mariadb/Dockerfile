# Base image
#FROM alpine:3.21.1
FROM public.ecr.aws/docker/library/alpine:3.21.1

#install mdb
RUN apk update && apk add \
	mariadb \
	mariadb-client \
	bash

#init script
COPY srcs/requirements/mariadb/tools/mdb_init.sh /usr/local/bin/mdb_init.sh
RUN chmod +x /usr/local/bin/mdb_init.sh

#mdb config
COPY srcs/requirements/mariadb/conf/mdb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod u=rw,go=r /etc/mysql/mariadb.conf.d/50-server.cnf

#expose port (for WP connection)
EXPOSE 3306

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]

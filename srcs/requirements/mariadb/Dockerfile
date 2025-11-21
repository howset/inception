# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install mdb
RUN apk update && apk add \
	mariadb \
	mariadb-client \
	bash

#init script
COPY ./tools/mdb_init.sh /usr/local/bin/mdb_init.sh
RUN chmod +x /usr/local/bin/mdb_init.sh

#mdb config
COPY ./conf/mdb.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN chmod u=rw,go=r /etc/my.cnf.d/mariadb-server.cnf

#expose port (for WP connection)
EXPOSE 3306

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]
#CMD ["mariadbd", "--user=mysql", "--datadir=/var/lib/mysql"]
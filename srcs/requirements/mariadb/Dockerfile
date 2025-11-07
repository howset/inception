# Base image
FROM alpine:3.21.1

# Install MariaDB
RUN apk update && apk add\
	bash\
	mariadb\
	mariadb-client

# Initialization script
COPY tools/mdb_init_alp.sh /usr/local/bin/mdb_init.sh
RUN chmod +x /usr/local/bin/mdb_init.sh

# MariaDB config
COPY conf/mdb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod u=rw,go=r /etc/mysql/mariadb.conf.d/50-server.cnf

# Expose port (for WP connection)
EXPOSE 3306

# Use the init script as the container's entrypoint
ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]
CMD ["mariadb"]

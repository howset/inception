# Base image
FROM alpine:3.21.1

#install nginx
RUN apk update && apk add \
	nginx \
	openssl \
	bash

#init script
COPY tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

#nginx config
COPY conf/nginx.cnf /etc/nginx/nginx.conf

#expose port (HTTP & HTTPS)
EXPOSE 80 443

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]
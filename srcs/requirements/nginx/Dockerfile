# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install nginx
RUN apk update && apk add \
	nginx \
	openssl \
	nano curl

#init script
COPY ./tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

#nginx config, NOT overwrite
COPY ./conf/nginx.cnf /etc/nginx/http.d/secure.conf

#expose port (none here, public exposure in docker-compose)

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]
# CMD [ "nginx", "-g", "daemon off;" ]

# Base image
FROM alpine:3.22.2
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install dependencies
RUN apk update && apk add --no-cache\
	php83 \
	php83-session \
	php83-mysqli \
	php83-pdo_mysql \
	php83-mbstring \
	php83-json

#get adminer
RUN wget -O /usr/share/adminer.php \
	"https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php" \
	&& chmod u=rw,g=r,o=r /usr/share/adminer.php

#init script
COPY tools/adminer_init.sh /usr/local/bin/adminer_init.sh
RUN chmod +x /usr/local/bin/adminer_init.sh

WORKDIR /usr/share

#expose port (purely metadata)
#EXPOSE 8080

#use the init script as entrypoint
#ENTRYPOINT ["/usr/local/bin/adminer_init.sh"]
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/usr/share", "adminer.php"]

# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install dependencies
RUN apk update && apk add --no-cache\
	php83 \
	php83-session \
	php83-mysqli \
	php83-pdo_mysql \
	php83-mbstring \
	php83-json
	# && ln -s /usr/bin/php83 /usr/bin/php

RUN wget -O /usr/share/adminer.php \
	"https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php" \
	&& chmod u=rw,g=r,o=r /usr/share/adminer.php

WORKDIR /usr/share

#expose port (purely metadata)
#EXPOSE 8080

#use the init script as entrypoint
#ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/usr/share", "adminer.php"]
# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install php-fpm & utils
RUN apk update && apk add \
	php83 \
	php83-fpm \
	php83-mysqli \
	php83-json \
	php83-opcache \
	php83-gd \
	php83-pecl-imagick \
	php83-curl \
	php83-xml \
	php83-xmlreader \
	php83-simplexml \
	php83-zip \
	php83-dom \
	php83-iconv \ 
	php83-mbstring \
	php83-phar \
	php83-session \
	php83-openssl \
	php83-tokenizer \
	php83-fileinfo \
	openssl \
	imagemagick \
	icu-data-full \
	mariadb-client \
	curl nano gettext

#get wp-cli
RUN curl -o /usr/local/bin/wp-cli.phar \
	https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp-cli.phar && \
	mv /usr/local/bin/wp-cli.phar /usr/local/bin/wp

#init script
COPY ./tools/wp_init.sh /usr/local/bin/wp_init.sh
RUN chmod +x /usr/local/bin/wp_init.sh

#wp config, overwrite it later in the script
COPY ./conf/wp.conf /etc/php83/php-fpm.d/www.conf.template

#expose port (purely metadata)
#EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
# CMD ["php-fpm83", "-F"]

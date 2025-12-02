# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install redis
RUN apk update && apk add --no-cache\
	redis

#init script
COPY tools/redis_init.sh /usr/local/bin/redis_init.sh
RUN chmod +x /usr/local/bin/redis_init.sh

#create dir for redis data
RUN mkdir -p /data && chown redis:redis /data

#expose port (purely metadata)
#EXPOSE 6379

#use the init script as entrypoint
ENTRYPOINT ["/usr/local/bin/redis_init.sh"]
#CMD [ "redis-server", "--bind", "0.0.0.0", "--protected-mode", "no", "--dir", "/data" ]

# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install redis
RUN apk update && apk add --no-cache\
	redis

#create dir for redis data
RUN mkdir -p /data && chown redis:redis /data

#expose port (purely metadata)
#EXPOSE 6379

#use the init script as entrypoint
#ENTRYPOINT ["/usr/local/bin/mdb_init.sh"]
CMD [ "redis-server", "--bind", "0.0.0.0", "--protected-mode", "no", "--dir", "/data" ]

#protected mode is no bcause redis is isolated on inception_net,
# not exposed to host, so authentication is not required
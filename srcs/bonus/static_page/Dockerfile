# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install nothing

#init script
COPY ./tools/staticp_init.sh /usr/local/bin/staticp_init.sh
RUN chmod +x /usr/local/bin/staticp_init.sh

#the static page
COPY ./contents/ /tmp/jumper/

ENTRYPOINT ["/usr/local/bin/staticp_init.sh"]
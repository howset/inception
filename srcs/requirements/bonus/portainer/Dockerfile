# Base image
FROM alpine:3.21.1
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install packages/dependencies
RUN apk add --no-cache \
	curl \
	ca-certificates

#get portainer
RUN curl -L https://github.com/portainer/portainer/releases/download/2.33.5/portainer-2.33.5-linux-amd64.tar.gz \
	-o /usr/local/bin/portainer.tar.gz && \
	tar -xzf /usr/local/bin/portainer.tar.gz -C /usr/local/bin/ && \
	rm -rf /usr/local/bin/portainer.tar.gz && \
	chmod +x /usr/local/bin/portainer/portainer

#create data directory
RUN mkdir -p /data

#init script
COPY tools/portainer_init.sh /usr/local/bin/portainer_init.sh
RUN chmod +x /usr/local/bin/portainer_init.sh

# Expose Portainer ports
EXPOSE 9000 9443 8000

# Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
#     CMD wget --no-verbose --tries=1 --spider http://localhost:9000/api/status || exit 1

ENTRYPOINT ["/usr/local/bin/portainer_init.sh"]
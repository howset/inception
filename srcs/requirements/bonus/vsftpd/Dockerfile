# Base image
FROM alpine:3.22.2
#FROM public.ecr.aws/docker/library/alpine:3.21.1

#install vsftpd
RUN apk add --no-cache \
	vsftpd \
	openssl

#init script
COPY tools/vsftpd_init.sh /usr/local/bin/vsftpd_init.sh
RUN chmod +x /usr/local/bin/vsftpd_init.sh

#config file
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

#create FTP user home directory
RUN mkdir -p /home/ftpuser

#expose ports
#21: Command port
#21000-21010: Passive mode data ports
#EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/vsftpd_init.sh"]
# CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]
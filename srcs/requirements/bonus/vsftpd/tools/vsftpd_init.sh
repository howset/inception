#!/bin/sh
set -e

RED='\033[0;31m'
GRE='\033[0;32m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running vsftpd_init.sh${RES}"

# Read credentials from secrets
FTP_USER="${FTP_USER}"
FTP_PASSWORD="$(cat /run/secrets/ftp_pw)"

# Create FTP user if doesn't exist
if ! id "$FTP_USER" >/dev/null 2>&1; then
	echo -e "${MAG}Creating FTP user: $FTP_USER${RES}"
	adduser -D -G www-data -h /home/$FTP_USER -s /bin/sh "$FTP_USER"
	echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
	echo -e "${GRE}FTP user created${RES}"
else
	echo -e "${GRE}FTP user already exists${RES}"
fi

# Add user to allowed list
echo "$FTP_USER" > /etc/vsftpd/user_list

# Set permissions
#chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
chmod ug=rwx,o=rx /home/$FTP_USER

echo -e "${GRE}FTP server setup complete!${RES}"

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

# exec "$@"
#!/bin/sh

RED='\033[0;31m'
GRE='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[0;34m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

echo -e "${CYA}Running mdb_init.sh${RES}"

start_mdb_bg()
{
	echo -e "${MAG}Installing/running mdb daemon${RES}"
	if [ ! -d /var/lib/mysql/mysql ]; then #create database
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi
	mkdir -p /run/mysqld #-p avoids errors if it already exists
	chown -R mysql:mysql /run/mysqld /var/lib/mysql #set mysql user and group
	chmod u=rwx,g=,o= /run/mysqld #set permissions so only owner mysql can read/write/execute in dir to improve security.
	mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking=0 & #mdb server daemon in bg, specify user, datadir, ensure networking is enabled
	sleep 5
	echo -e "${GRE}Installing/running mdb daemon...Done!${RES}"
}

#reproduce mysql_secure_installation noninteractively
apply_msi()
{
	echo -e "${MAG}Applying mysql_secure_installation manually${RES}"
	mariadb -e "DELETE FROM mysql.user WHERE User='';" #remove anon users
	mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" #allow only localhost/root access
	mariadb -e "DROP DATABASE IF EXISTS test;" #remove default test db
	mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" #Remove privileges related to it
	mariadb -e "FLUSH PRIVILEGES;" #apply immediately
	echo -e "${GRE}Applying mysql_secure_installation manually...Done!${RES}"
}

setup_db()
{
	local DB_USER_PW=$(cat /run/secrets/DB_USER_PW)
	echo -e "${MAG}Setting up the database${RES}"
	mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" #create db
	mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER_NAME}'@'%' IDENTIFIED BY '$DB_USER_PW';" #adds new user with password, allowing connection from any host ('%')
	mariadb -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'%';" #give full privilege to user
	mariadb -e "FLUSH PRIVILEGES;"
	echo -e "${GRE}Setting up the database...Done!${RES}"
}

start_mdb_bg
apply_msi
setup_db

# stop temporary background server
pkill -f mariadbd || true
sleep 1

echo -e "${GRE}MariaDB setup complete!${RES}"

# Start MariaDB server in the foreground (PID 1)
exec mariadbd --user=mysql --datadir=/var/lib/mysql
# exec "$@"

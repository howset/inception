#!/bin/bash

#exit immediately if any command fails, prevents the container from silently continuing if something breaks
set -e

start_mdb_bg()
{
	if [ ! -d /var/lib/mysql/mysql ]; then #create database
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	fi
	mkdir -p /run/mysqld #-p avoids errors if it already exists
	chown -R mysql:mysql /run/mysqld /var/lib/mysql #set mysql user and group
	chmod u=rwx,g=,o= /run/mysqld #set permissions so only owner mysql can read/write/execute in dir to improve security.
	mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking=0 & #mdb server daemon in bg, specify user, datadir, ensure networking is enabled
	sleep 5
}

#reproduce mysql_secure_installation noninteractively
apply_msi()
{
	mariadb -e "DELETE FROM mysql.user WHERE User='';" #remove anon users
	mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" #allow only localhost/root access
	mariadb -e "DROP DATABASE IF EXISTS test;" #remove default test db
	mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" #Remove privileges related to it
	mariadb -e "FLUSH PRIVILEGES;" #apply immediately
}

setup_db()
{
	local DATABASE_NAME=MDB_NAME666
	local DATABASE_USER_NAME=MDB_USER666
	local DATABASE_USER_PASSWORD=MDB_PASSWD666

	mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;" #create db
	mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';" #adds new user with password, allowing connection from any host ('%')
	mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';" #give full privilege to user
	mariadb -e "FLUSH PRIVILEGES;"
}

start_mdb_bg
apply_msi
setup_db

# stop temporary background server
#if pgrep mariadbd >/dev/null 2>&1; then #check if mdb is running
#	mysqladmin --user=root shutdown 2>/dev/null || pkill mariadbd #stop nicely or kill it
#	while pgrep mariadbd >/dev/null 2>&1; do sleep 0.1; done #waits until process fully exits
#fi
pkill -f "mariadbd.*skip-networking" || true

# Start MariaDB server in the foreground (PID 1)
exec mariadbd --user=mysql --datadir=/var/lib/mysql "$@"
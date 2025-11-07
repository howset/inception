#!/bin/bash
set -e

start_mdb_bg()
{
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld /var/lib/mysql
	chmod a=rwx /run/mysqld
	mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking=0 --bind-address=0.0.0.0 &
	sleep 5
}

apply_secure_fixes()
{
	mariadb -e "DELETE FROM mysql.user WHERE User='';"
	mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	mariadb -e "DROP DATABASE IF EXISTS test;"
	mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
	mariadb -e "FLUSH PRIVILEGES;"
}

setup_db()
{
	local DATABASE_NAME=MDB_NAME666
	local DATABASE_USER_NAME=MDB_USER666
	local DATABASE_USER_PASSWORD=MDB_PASSWD666

	mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
	mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
	mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
	mariadb -e "FLUSH PRIVILEGES;"
}

start_mdb_bg
apply_secure_fixes
setup_db

pkill mariadbd

# Start MariaDB server in the foreground (PID 1)
exec mariadbd --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0

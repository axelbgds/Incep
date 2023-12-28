#!/bin/bash

# Check if the directory '/var/run/mysqld' exists and create it if it doesn't exist
# Set the owner and group of this directory to 'mysql:mysql'
# This directory is used by MySQL to store runtime informations such as process IDs and socket files
if [ ! -d "/var/run/mysqld" ]; then
        mkdir -p /var/run/mysqld
        chown -R mysql:mysql /var/run/mysqld
fi

# Check if the directory '/etc/my.cnf.d' exists and create it if it doesn't exist
# Set the owner and group of the directory to 'mysql:mysql'
# This directory is used by MySQL to store the server configuration files
if [ ! -d "/etc/my.cnf.d" ]; then
        mkdir -p /etc/my.cnf.d
        chown -R mysql:mysql /etc/my.cnf.d
fi

# Create a new configuration file '/etc/my.cnf.d/docker.cnf' for the MySQL or MariaDB server database
echo '[mysqld]' > /etc/my.cnf.d/docker.cnf
# Tell the server to skip caching host names for faster performance
echo 'skip-host-cache' >> /etc/my.cnf.d/docker.cnf
# Tell the server to skip DNS lookups for faster performance
echo 'skip-name-resolve' >> /etc/my.cnf.d/docker.cnf
# Tell the server to listen on all network interfaces
echo 'bind-address=0.0.0.0' >> /etc/my.cnf.d/docker.cnf
# Replace the line "skip-networking" by "skip-networking=0" to instruct the MariaDB server to allow connections from outside the container
sed -i "s/skip-networking/skip-networking=0/g" /etc/my.cnf.d/mariadb-server.cnf


# Check if the directory '/var/lib/mysql/mysql' exists and create it if it doesn't exist
# Set the owner and group of this directory to 'mysql:mysql'
# Run the 'mysql_install_db' command to initialize the MySQL database directory and system tables
# The '--user' option specifies that the installation process should be performed as the 'mysql' user which is the user that the MariaDB server runs as
# The '--datadir' option specifies the location where the MySQL data files will be stored which is owned by the 'mysql' user
# The '--basedir' option specifies the base directory where the MySQL distribution is installed
# The '--rpm' option indicates that the script is running on an RPM-based Linux distribution
# The script will try to create and write in a tempory file to check if something went wrong during the installation process
if [ ! -d "/var/lib/mysql/mysql" ]; then
        chown -R mysql:mysql /var/lib/mysql
        mysql_install_db --user=mysql --datadir=/var/lib/mysql --basedir=/usr --rpm
        tempfile=`mktemp`
        if [ ! -f "$tempfile" ]; then
                return 1
        fi
fi

# Create a new database and user with the provided credentials and grants all privileges on the new database to the new user
# It also removes the default test database and user and deletes any empty users from the MySQL mysql database
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
        cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED by '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF
        /usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql
        rm -f /tmp/create_db.sql
fi

# docker exec -it mariadb mysql -uabeaugra -p
# USE wordpress
# SHOW tables;
# SELECT * FROM wp_users;

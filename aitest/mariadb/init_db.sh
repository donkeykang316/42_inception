#!/bin/sh

if [ ! -d "/var/lib/mysql/mysql" ]; then
    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    # Start MariaDB in the background
    mysqld_safe --datadir=/var/lib/mysql &

    sleep 5

    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
    MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)
    MYSQL_ADMIN_PASSWORD=$(cat /run/secrets/mysql_admin_password)

    # Create database and users
    mysql -u root <<-EOSQL
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
        CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_ADMIN_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Stop MariaDB
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
fi

exec mysqld_safe --datadir=/var/lib/mysql

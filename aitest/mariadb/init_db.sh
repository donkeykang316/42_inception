#!/bin/sh

set -e

# Function to log messages
log() {
  echo "[init_db.sh] $1"
}

# Initialize the database if it hasn't been initialized yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    log "Initializing MariaDB database..."

    # Set ownership and permissions
    chown -R mysql:mysql /var/lib/mysql
    chmod 755 /var/lib/mysql

    # Initialize the database
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    # Start MariaDB in the background
    log "Starting MariaDB in the background for setup..."
    mysqld_safe --datadir=/var/lib/mysql --user=mysql &
    pid="$!"

    # Wait until MariaDB is ready to accept connections
    log "Waiting for MariaDB to start..."
    until mysql -u root -e "SELECT 1" > /dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
    echo

    # Read passwords from Docker secrets
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
    MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)
    MYSQL_ADMIN_PASSWORD=$(cat /run/secrets/mysql_admin_password)

    # Create database and users
    log "Setting up database and users..."
    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
        CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
        CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_ADMIN_USER}'@'%';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_ADMIN_USER}'@'localhost';
        FLUSH PRIVILEGES;
EOSQL

    # Gracefully shut down the background MariaDB process
    log "Shutting down temporary MariaDB process..."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    # Wait for the background process to terminate
    wait "$pid"
fi

# Start MariaDB in the foreground
log "Starting MariaDB in the foreground..."
exec mysqld_safe --datadir=/var/lib/mysql --user=mysql

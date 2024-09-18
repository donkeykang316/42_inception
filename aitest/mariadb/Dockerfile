FROM alpine:3.17

# Install MariaDB and necessary packages
RUN apk update && \
    apk add --no-cache mariadb mariadb-client

# Create necessary directories and set ownership
RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql && \
    chmod 755 /run/mysqld /var/lib/mysql /var/log/mysql

# Copy custom MariaDB configuration
COPY my.cnf /etc/my.cnf

# Copy and set permissions for the initialization script
COPY init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

# Expose MariaDB port
EXPOSE 3306

# Set the entrypoint to the initialization script
CMD ["/init_db.sh"]

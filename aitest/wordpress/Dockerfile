FROM alpine:3.17

# Install necessary packages
RUN apk update && \
    apk add --no-cache php81 php81-fpm php81-mysqli php81-json php81-curl \
    php81-mbstring php81-xml php81-gd php81-zip php81-openssl wget

# Create www-data user if it doesn't exist, and assign to www-data group
RUN id -u www-data &>/dev/null || adduser -S www-data -G www-data

# Download and set up WordPress
RUN mkdir -p /var/www/html && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzvf latest.tar.gz --strip-components=1 -C /var/www/html && \
    rm latest.tar.gz

# Copy custom wp-config.php
COPY wp-config.php /var/www/html/

# Set ownership of files to www-data
RUN chown -R www-data:www-data /var/www/html

# Configure PHP-FPM to use www-data user and group
RUN sed -i "s/;daemonize = yes/daemonize = no/" /etc/php81/php-fpm.conf && \
    sed -i "s/127.0.0.1:9000/0.0.0.0:9000/" /etc/php81/php-fpm.d/www.conf && \
    sed -i "s/user = nobody/user = www-data/" /etc/php81/php-fpm.d/www.conf && \
    sed -i "s/group = nobody/group = www-data/" /etc/php81/php-fpm.d/www.conf

EXPOSE 9000

CMD ["php-fpm81", "-F", "--nodaemonize"]

FROM    debian:bullseye

#incstall nginx and openssl
RUN     apt-get update && \
        apt-get upgrade -y && \
        apt-get install -y nginx openssl

RUN     mkdir -p /etc/nginx/ssl && \
        openssl req -x509 -nodes -days 300 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=DE/ST=Berlin/L=Berlin/O=Global Security/OU=IT Department/CN=test.com"

COPY    ./conf/nginx.conf /etc/nginx/nginx.conf

# Expose port 443 (HTTPS)
EXPOSE  443

# start nginx in the foreground (daemon mode off)
CMD     ["nginx", "-g", "daemon off;"]
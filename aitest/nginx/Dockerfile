FROM alpine:3.17

ARG DOMAIN_NAME

# Install NGINX and OpenSSL
RUN apk update && \
    apk add --no-cache nginx openssl

# Generate SSL certificates
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=${DOMAIN_NAME}" \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/selfsigned.key \
        -out /etc/nginx/ssl/selfsigned.crt

# Remove the default NGINX configuration file
RUN rm /etc/nginx/http.d/default.conf

# Copy your custom NGINX configuration file
COPY default.conf /etc/nginx/http.d/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

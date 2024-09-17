FROM alpine:3.17

RUN apk update && \
    apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY my.cnf /etc/my.cnf

COPY init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

CMD ["/init_db.sh"]

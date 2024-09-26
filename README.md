## Set Up the Development Environment
- `sudo apt update`
- `sudo apt install docker.io`
- `sudo apt install docker-compose`
### in case the permision denial when running "docker version"
- check the if the user within the docker user group: `getent group docker`
- add user to the docker group: `sudo usermod -aG docker $USER`

### in case the docker compose execution error
- check the build of docker compose `docker-compose --version`
- id the build is shown unknow, execute the following shell scripts
- `DOCKER_COMPOSE_VERSION=$(curl -Ls "https://api.github.com/repos/docker/compose/releases/latest" | grep -Po '"tag_name": "\K[^\s,]*' | sed 's/^v//')
sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose`
- `sudo chmod +x /usr/local/bin/docker-compose`
- `sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose`

### run docker
- create docker image by running the docker file: `docker build -t program_name program_path` "." for current path
- check image details: `docker image ls`
- run the program from the container: `docker run program_name`

### containers cleanup
- clear all running containers: `docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null`

### docker debug
- `docker logs <containerID>`

### run muliple containers using docker-compose.yml
- run docker compose: `docker-compose up`

### access container
- `docker exec -it container_ID_or_name /bin/sh`

### database login
- `mysql -u theuser -p thedatabase`

### show DB table
- `SHOW TABLES;`

## MariaDB

### Dockerfile breakdown
- `FROM` get debian:bullseye image
- `EXPOSE` this container will be available on port 3306
- `RUN` get the all the system update and install mariadb in side the container, clean apt cache for saving disk space
- `COPY` the local 50-server.conf (contains custom MariaDB server configuration settings) and  the local setup.sh (Mariadb service setup) into the container and `RUN` to to allow the execution right of the setup.sh
- `CMD` conatiner execute setup.sh and mysqld_safe (a script provided by MariaDB that starts the MariaDB server in a "safe" mode. It is often used to monitor the server and restart it in case of failure.)

### 50-server.cnf breakdown
- It's a default file
- file name: The numeric prefix (50-) is used to determine the load order of configuration files. Files are usually loaded in alphanumeric order, so having numbers at the beginning helps control the sequence.  The 50- prefix suggests that this is a mid-level priority configuration file.
- `mysqld` main section for configuring the MariaDB server daemon (mysqld). The parameters listed here directly affect the behavior of the MariaDB server, all parameters in this case are default beside the port (port = 3306)
- File Purpose: customizing Server Behavior, optimizing performance etc.
- for more configuration see this example [example](https://exampleconfig.com/view/mariadb-ubuntu18-04-etc-mysql-mariadb-conf-d-50-server-cnf)

### setup.sh breakdown
- Shebang `#!/bin/bash`: tells the system that the script should be executed using the bash shell
- start the service with `service mariadb start`
- `mariadb -v -u root << EOF` this initiates an interactive MariaDB session using the root user and execute SQL command as:
 - Creates a new database with the name stored in the $DB_NAME environment variable, but only if it doesn't already exist
 - Creates a new MariaDB user with the name stored in $DB_USER and password $DB_PASSWORD, but only if the user doesn't already exist. The @'%' part allows this user to connect from any host
 - Grants all privileges on the newly created database ($DB_NAME) to the user ($DB_USER)
 - Sets a new password for the root user connecting from localhost to $DB_PASS_ROOT. This ensures the root user has the correct password set
- `sleep 5` pause the script for 5 seconds to process SQL coomands above and then stop the service with `service mariadb stop`
- `exec $@` The exec command replaces the current shell process with `$@` which represent in this case starting mysqld_safe to keep the container up

## Wordpress

### Dockerfile breakdown
- `FROM` get debian:bullseye image
- `EXPOSE` available at port 9000
- `RUN` download all the dependencies for setting up wordpress: `ca-certificates`  package that provides a set of trusted Certificate Authority (CA) certificates used to verify SSL/TLS connections. `php7.4-fpm` FastCGI Process Manager, it is a version of PHP that is specifically designed to handle and manage web requests more efficiently using the FastCGI protocol. php7.4-fpm is a specific version of PHP designed to handle web requests efficiently and is often used in high-traffic, performance-oriented environments. `php7.4-mysql` is a PHP extension that provides MySQL database support for PHP 7.4. It allows PHP scripts to interact with MySQL databases, enabling them to perform operations like connecting to the database, executing queries, fetching data, and managing database records. This package is essential for any PHP application that needs to work with MySQL databases, such as WordPress or other web applications relying on MySQL for data storage.
- `sed -i 's/str1/str2/g'` (Stream Editor) modify file content by replacing str1 with str2, flag i make the in file modification possible. The sed "sed script" here sets cgi.fix_pathinfo=0 to enhance security by preventing PHP from misinterpreting path information, Changes the listening address from a Unix socket to port 9000.
Ensures the socket has the correct permissions (0660).
Disables daemonization so that PHP-FPM runs in the foreground, which is necessary for Docker containers.
- `RUN` download the WP-CLI tool, a command-line interface for managing WordPress installations and makes it executable and moves it to /usr/local/bin for global access.
- `CMD` run the shell script and execute PHP-FPM in the foreground, which is necessary for Docker containers to keep running
- NOTE: wordpress cannot run without DB

### wp-config.php
- default file, uses getenv() to retrieve these values from environment variables, enhancing security by avoiding hard-coded credentials
- [file guide](https://developer.wordpress.org/apis/wp-config-php/)

### www.conf
- also known as PHP-FPM (FastCGI Process Manager) pool or look for PHP configuration for guidline like [this one](https://www.php.net/manual/en/install.fpm.configuration.php)

### setup.sh
- Set Permissions: Ensures the web directory has the correct ownership.
- Configure WordPress: Moves the configuration file if it doesn't exist.
- Wait for Dependencies: Pauses execution to allow other services (like the database) to initialize.
Download WordPress Core: Downloads WordPress if it's not already present.
- Install WordPress: Runs the WordPress installation if it's not already installed.
Create an Admin User: Adds an additional WordPress user if it doesn't exist.
- Execute the Main Command: Starts the PHP-FPM process to keep the container running.

## nginx

### Dockerfile breakdown
- `RUN` install nginx and openssl which is essential for generating SSL/TLS certificates
- `ARG` declares build-time variables that can be passed to the Docker build process from the .env. CERT_FOLDER: Directory where SSL certificates will be stored.
CERTIFICATE: Path to the SSL certificate file.
KEY: Path to the SSL key file.
COUNTRY, STATE, LOCALITY, ORGANIZATION, UNIT, COMMON_NAME (DOMAIN_NAME): Components of the SSL certificate's subject information.
- `RUN` openssl req: Generates a new SSL certificate and key. -newkey rsa:4096: Creates a new RSA key of 4096 bits. -x509: Outputs a self-signed certificate instead of a certificate request. -sha256: Uses SHA-256 for hashing. -days 365: Sets the certificate validity period to 365 days. -nodes: Skips the option to secure the private key with a passphrase. -out ${CERTIFICATE}: Specifies the output certificate file. -keyout ${KEY}: Specifies the output key file. -subj: Defines the subject fields for the certificate
- `RUN echo "\tserver name ${COMMON_NAME}; ...` Appends SSL-related directives to the server.conf

### nginx.conf and server.conf
- You can try with [digitalocean](https://www.digitalocean.com/community/tools/nginx?domains.0.server.domain=login.42.fr&domains.0.php.phpServer=%2Fvar%2Frun%2Fphp%2Fphp7.4-fpm.sock&domains.0.php.phpBackupServer=%2Fvar%2Frun%2Fphp%2Fphp7.4-fpm.sock&global.app.lang=de) for generating both of the file or just use mine

## docker compose

### Overview
- the docker compose configuration defines three primary services: MariaDB: Acts as the database server for WordPress. WordPress: Runs the WordPress application, utilizing PHP-FPM for processing. Nginx: Serves as the reverse proxy and web server, handling HTTP/HTTPS requests and forwarding them to WordPress.

### MariaDB Service
- the container need a name for easy identification. `build` will look for the docker file from the given path. `volumes` is where the database files will be saved in the container. `networks` Connects the MariaDB service to the all network, in this case with wordpress and nginx. `init` is used to run the setup.sh, restart is used to restart the container if it fails, and env_file is the file that contains the variables that will be used in the container

### Wordpress Service
- the wordpress service is similar to the mariadb service, but it has a depends_on field that indicates that the wordpress container will only start after the mariadb container is running.

### nginx Service

- `build: context:` looks for the corresponding docker. `args` passes build-time variables to the Docker build process, when building the image, these arguments are set via environment variables defined in the .env file or directly in the command line. The rest are similiar like wordpress setup

### Volumes

- define the local  that will be used to save the database and the wordpress files. The subject informs that the data must be in user home directory. This volumes will work like a shared folder between the host and the containers

### Networks

- defines a custom network named all using Docker's bridge driver which is the docker's default bridge network driver. The bridge provides network isolation and allows containers to communicate with each other.

## Huge aprreciation of the guide line from [waltergcc](https://github.com/waltergcc/42-inception?tab=readme-ov-file#13-nginx)

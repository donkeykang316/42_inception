## Set Up the Development Environment
- `sudo apt update`
- `sudo apt install docker.io`
- `sudo apt install docker-compose`
### in case the permision denial when running "docker version"
- check the if the user within the docker user group: `getent group docker`
- add user to the docker group: `sudo usermod -aG docker $USER`
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


## MariaDB

### Dockerfile breakdown
- `FROM` get debian:bullseye image
- `EXPOSE` this container will be listening on port 3306
- `RUN` get the all the system update and install mariadb in side the container, clean apt cache for saving disk space
- `COPY` the local 50-server.conf (contains custom MariaDB server configuration settings) and  the local setup.sh (Mariadb service setup) into the container and `RUN` to to allow the execution right of the setup.sh
- `CMD` conatiner execute setup.sh and mysqld_safe (a script provided by MariaDB that starts the MariaDB server in a "safe" mode. It is often used to monitor the server and restart it in case of failure.)

### 50-server.cnf breakdown
- It's a default file
- file name: The numeric prefix (50-) is used to determine the load order of configuration files. Files are usually loaded in alphanumeric order, so having numbers at the beginning helps control the sequence.  The 50- prefix suggests that this is a mid-level priority configuration file.
- `server` used for global settings that apply to all MariaDB server instances and plugins
- `mysqld` main section for configuring the MariaDB server daemon (mysqld). The parameters listed here directly affect the behavior of the MariaDB server, all parameters in this case are default beside the port (port = 3306)
- `embedded mariadb mariadb-10.3` all default section which are empty in this case
- File Purpose: customizing Server Behavior, optimizing performance etc.

### setup.sh breakdown
- Shebang `#!/bin/bash`: ells the system that the script should be executed using the bash shell
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
- `EXPOSE` listen port 9000
- `RUN` download all the dependencies for setting up wordpress: `ca-certificates`  package that provides a set of trusted Certificate Authority (CA) certificates used to verify SSL/TLS connections. `php7.4-fpm` FastCGI Process Manager, it is a version of PHP that is specifically designed to handle and manage web requests more efficiently using the FastCGI protocol. php7.4-fpm is a specific version of PHP designed to handle web requests efficiently and is often used in high-traffic, performance-oriented environments. `php7.4-mysql` is a PHP extension that provides MySQL database support for PHP 7.4. It allows PHP scripts to interact with MySQL databases, enabling them to perform operations like connecting to the database, executing queries, fetching data, and managing database records. This package is essential for any PHP application that needs to work with MySQL databases, such as WordPress or other web applications relying on MySQL for data storage.
- `sed -i 's/str1/str2/g'` (Stream Editor) modify file content by replacing str1 with str2, flag i make the in file modification possible

## Set Up the Development Environment
- `sudo apt update`
- `sudo apt install docker.io`
- `sudo apt install docker-compose`
### in case the permision denial when running "docker version"
- check the if the user within the docker user group: `getent group docker`
- add user to the docker group: `sudo usermod -aG docker $USER`
  

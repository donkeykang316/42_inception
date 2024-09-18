include .env
export $(shell sed 's/=.*//' .env)

all: build up add-host

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down -v

show:
	@docker image ls -a && echo "\n" && docker ps -a

clean: down
	docker system prune -af
	docker volume rm $(docker volume ls -q)

add-host:
	@echo "Adding entry to /etc/hosts if not present"
	@echo "DOMAIN_NAME is ${DOMAIN_NAME}"
	@sudo sh -c 'grep -q "${DOMAIN_NAME}" /etc/hosts || echo "127.0.0.1   ${DOMAIN_NAME}" >> /etc/hosts'

.PHONY: all build up down clean

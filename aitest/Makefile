.PHONY: all build up down clean

all: build up

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

clean: down
	docker system prune -af
	docker volume rm $(docker volume ls -q)
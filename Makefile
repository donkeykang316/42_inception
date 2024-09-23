NAME	= inception

all: $(NAME)

$(NAME): up

up:
	@docker-compose -p $(NAME) -f ./srcs/docker-compose.yml up --build

show:
	@docker image ls -a && echo "\n" && docker ps -a

clean:
	@docker stop $$(docker ps -qa); \
	docker rm $$(docker ps -qa); \
	docker rmi -f $$(docker images -qa); \
	if [$$(docker volume ls -q)]; then \
		docker volume rm $$(docker volume ls -q); \
	fi; \
	if [$$(docker network ls -q | grep -v "bridge\|host\|none")]; then \
		docker network rm $$(docker network ls -q | grep -v "bridge\|host\|none"); \
	fi 2>/dev/null; \
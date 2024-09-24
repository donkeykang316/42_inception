NAME		= inception
HOST_URL	= kaan.42.fr

all: $(NAME)

$(NAME): up

up:
	@mkdir -p ~/data/database
	@mkdir -p ~/data/wordpress_files
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_ADD)"
	@docker-compose -p $(NAME) -f ./srcs/docker-compose.yml up --build

show:
	@docker image ls -a && echo "\n" && docker ps

backend:
	@docker exec -it nginx /bin/sh

db:
	@docker exec -it mariadb /bin/sh

frontend:
	@docker exec -it wordpress /bin/sh

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

fclean: clean
	@sudo rm -rf ~/data
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_RM)"

HIDE		= /dev/null 2>&1
HOST_ADD 	= Host $(HOST_URL) added
HOST_RM		= Host $(HOST_URL) removed

.PHONY: all up clean fclean re
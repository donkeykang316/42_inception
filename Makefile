all:
	docker-compose -f ./srcs/docker-compose.yml up

show:
	docker image ls -a && echo "\n" && docker ps -a

run:
	docker run -d -p 80:80 -p 8443:443 nginx_server

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
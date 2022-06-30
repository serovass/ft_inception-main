all: start

start:
	cd srcs && sudo docker-compose up

stop:
	cd srcs && sudo docker-compose down

clean:
	yes | sudo docker container prune
	sudo docker image rm -f srcs_myimage_web \
							srcs_myimage_wordpress \
							srcs_myimage_db
	yes | sudo docker image prune
	yes | sudo docker volume prune
	sudo rm -rf /home/gnaida/data/db/*
	sudo rm -rf /home/gnaida/data/wordpress/*

.PHONY: all, start, stop, clean
#!/bin/zsh
#fall on errors
set -e

docker build -t tapcat/nginx .  
#https://github.com/dotcloud/docker/issues/1150
# docker 0.5 return 0 anyway
#Let's stop previous nginx container
NGINX_CONTAINER=$(docker ps | grep -w "80->80" | awk '{ print $1 }') 
if [ -n $NGINX_CONTAINER ]; then
	docker stop $NGINX_CONTAINER
fi;
docker run -d -p 80:80 tapcat/nginx

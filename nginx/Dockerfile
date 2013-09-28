FROM ubuntu:precise
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get -y install python-software-properties
RUN add-apt-repository ppa:nginx/stable
RUN apt-get update

RUN apt-get install -y nginx

ADD nginx.conf /etc/nginx/nginx.conf
EXPOSE 80:80
ENTRYPOINT nginx && tail -f /var/log/nginx/error.log 

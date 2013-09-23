FROM ubuntu:precise
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get -y install python-software-properties
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update && apt-get -y upgrade

# automatically accept oracle license
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# and install java 7 oracle
RUN apt-get -y install oracle-java7-installer && apt-get clean
RUN update-alternatives --display java
RUN echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/environment
# java installed
RUN wget "http://eclipse.org/downloads/download.php?file=/jetty/stable-9/dist/jetty-distribution-9.0.5.v20130815.tar.gz&r=1" -O jetty.tar.gz
RUN tar -xvf jetty.tar.gz
RUN rm jetty.tar.gz
RUN mv jett* /opt/jetty
RUN rm -rf /opt/jetty/webapps.demo
RUN useradd jetty -U -s /bin/false
RUN chown -R jetty:jetty /opt/jetty
RUN cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty
ADD ./jetty-config /etc/default/jetty
ADD /home/travis/tapcat-webserver.war /opt/jetty/webapps
EXPOSE 80:8085
VOLUME /home/tapcat/logs:/opt/jetty/logs
CMD service jetty start && tail -f cat /opt/jetty/logs/*errout.log

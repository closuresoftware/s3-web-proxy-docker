FROM tomcat:8.0
MAINTAINER Narciso Cerezo <narciso@closure.software>
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8080
EXPOSE 8009

VOLUME /var/lib/s3proxy/cache

# small utility to generate password file entries
COPY password-gen.sh /usr/local/bin/password-gen
RUN chmod 755 /usr/local/bin/password-gen

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh

# You must override these
COPY default-users.auth /var/lib/s3proxy
ENV S3PROXY_AUTH_FILE "file:/var/lib/s3proxy/default-users.auth"

ENV CATALINA_OPTS "-XX:MaxPermSize=128m -Xms384m -Xmx384m"

# remove all default tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# copy app configuration file
RUN mkdir -p /root/.grails
COPY s3-web-proxy-config.groovy /root/.grails/

# copy app
RUN wget -O /usr/local/tomcat/webapps/ROOT.war https://s3-eu-west-1.amazonaws.com/closure-downloads/s3-web-proxy-0.2.1.war

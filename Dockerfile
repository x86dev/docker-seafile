FROM phusion/baseimage
# Initially was based on work of Alessandro Viganò
MAINTAINER Andreas Löffler <andy@x86dev.com>

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y ca-certificates \
                       nginx \
                       python2.7 python-flup python-imaging python-mysqldb python-setuptools \
                       sqlite3 dnsmasq

ENV SERVER_NAME example
ENV SERVER_ADDR seafile.example.com
ENV ADMIN_EMAIL admin@example.com
ENV ADMIN_PASSWORD changeme!

RUN mkdir /opt/seafile
WORKDIR /opt/seafile
RUN curl -L -O https://bitbucket.org/haiwen/seafile/downloads/seafile-server_4.1.2_x86-64.tar.gz
RUN tar xzf seafile-server_*
RUN mkdir installed
RUN mv seafile-server_* installed

# Install DnsMasq service.
RUN mkdir /etc/service/dnsmasq
ADD service-dnsmasq.sh /etc/service/dnsmasq/run

# Install Seafile service.
RUN mkdir /etc/service/seafile
ADD service-seafile-run.sh /etc/service/seafile/run
ADD service-seafile-stop.sh /etc/service/seafile/stop

# Install Seahub service.
RUN mkdir /etc/service/seahub
ADD service-seahub-run.sh /etc/service/seahub/run
ADD service-seahub-stop.sh /etc/service/seahub/stop

# Install Nginx.
RUN mkdir /etc/service/nginx
ADD service-nginx.sh /etc/service/nginx/run
ADD seafile-nginx.conf /etc/nginx/sites-available/seafile

# Expose needed ports.
EXPOSE 10001 12001 8000 8082

RUN mkdir /opt/seafile/logs

VOLUME /etc
VOLUME /opt/seafile
VOLUME /etc/service/seafile
VOLUME /etc/service/seahub

ADD bootstrap-data.sh /usr/local/sbin/bootstrap
CMD /sbin/my_init


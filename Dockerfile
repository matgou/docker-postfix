FROM debian:9

EXPOSE 25/tcp

VOLUME /var/log/postfix

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes install postfix-mysql postfix rsyslog

ADD etc/ /etc/
ADD entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]

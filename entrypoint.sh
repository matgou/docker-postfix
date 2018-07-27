#!/bin/sh

if [ -z $MYSQL_DATABASE ]; then
        MYSQL_DATABASE="postfix"
fi

if [ -z $MYSQL_USER ]; then
        MYSQL_USER="root"
fi

if [ -z $MYSQL_PASSWORD ]; then
        MYSQL_PASSWORD="root"
fi

if [ -z $MYSQL_HOST ]; then
        MYSQL_HOST="database"
fi

if [ -z $MYSQL_PORT ]; then
        MYSQL_PORT=3306
fi

if [ -z $SSL_DIR ];
then
        echo "You must specify SSL DIRECTORY"
        exit 255
fi

if [ -z $MAIL_HOST ]
then
	echo "please complete MAIL_HOST environnement variable"
	exit 255
fi

find /etc/postfix/ -type f | while read fic
do  
	sed -i "s/@@MAIL_HOST@@/$MAIL_HOST/g" $fic
        sed -i "s/@@MYSQL_DATABASE@@/$MYSQL_DATABASE/g" $fic
        sed -i "s/@@MYSQL_USER@@/$MYSQL_USER/g" $fic
        sed -i "s/@@MYSQL_HOST@@/$MYSQL_HOST/g" $fic
        sed -i "s/@@MYSQL_PASSWORD@@/$MYSQL_PASSWORD/g" $fic
        sed -i "s/@@MYSQL_PORT@@/$MYSQL_PORT/g" $fic
        sed -i "s:@@SSL_DIR@@:$SSL_DIR:g" $fic
done

sed -i "s:/var/log/mail:/var/log/postfix/mail:g" /etc/rsyslog.conf

dovecot_ip=$( getent ahosts dovecot | awk '{ print $1 }' | head -1 )

sed -i "s:@@DOVECOT_IP@@:$dovecot_ip:" /etc/postfix/main.cf

/usr/sbin/rsyslogd &
/usr/lib/postfix/sbin/master -c /etc/postfix/ -d

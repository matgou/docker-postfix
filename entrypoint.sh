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
dovecot_ip=$( getent ahosts dovecot | awk '{ print $1 }' | head -1 )

find /etc/postfix/ -type f | while read fic
do  
	sed -i "s/@@MAIL_HOST@@/$MAIL_HOST/g" $fic
        sed -i "s/@@MYSQL_DATABASE@@/$MYSQL_DATABASE/g" $fic
        sed -i "s/@@MYSQL_USER@@/$MYSQL_USER/g" $fic
        sed -i "s/@@MYSQL_HOST@@/$MYSQL_HOST/g" $fic
        sed -i "s/@@MYSQL_PASSWORD@@/$MYSQL_PASSWORD/g" $fic
        sed -i "s/@@MYSQL_PORT@@/$MYSQL_PORT/g" $fic
        sed -i "s:@@SSL_DIR@@:$SSL_DIR:g" $fic
        sed -i "s:@@DOVECOT_IP@@:$dovecot_ip:g" $fic
done

sed -i "s:/var/log/mail:/var/log/postfix/mail:g" /etc/rsyslog.conf


# Create spool directory structure
mkdir -p /var/spool/postfix/{active,bounce,corrupt,defer,deferred,dev,etc,flush,incoming,lib,maildrop,pid,private,public,saved,usr}
mkdir -p /var/spool/postfix/usr/lib/sasl2 /var/spool/postfix/usr/lib/zoneinfo
chown postfix:root /var/spool/postfix/{active,bounce,corrupt,defer,deferred,flush,incoming,maildrop,private,public,saved}


# Reploace dovecot with ip in main.cf
sed -i "s:@@DOVECOT_IP@@:$dovecot_ip:" /etc/postfix/main.cf

# If exist delete pid file
rm /var/run/rsyslogd.pid
rm /var/spool/postfix/pid/master.pid

# Start rsyslogd
/usr/sbin/rsyslogd &

# Start postfix on foreground
/usr/lib/postfix/sbin/master -c /etc/postfix/ -d

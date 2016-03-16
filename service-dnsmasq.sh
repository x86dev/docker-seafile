#!/bin/sh

set -eu

exec dnsmasq --address /MYSQL/$DB_PORT_3306_TCP_ADDR --address /$SEAFILE_DOMAIN_NAME/127.0.0.1 -d

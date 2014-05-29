#!/bin/sh

set -eu

exec dnsmasq -A /MYSQL/$DB_PORT_3306_TCP_ADDR --address /localhost/$SEAFILE_DOMAIN_NAME -d

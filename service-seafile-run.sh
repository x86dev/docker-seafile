#!/bin/sh

set -eu

/opt/seafile/seafile-server-latest/seafile.sh start >> /var/log/service-seafile.log

while [ 1 ]; do
  sleep 10
done

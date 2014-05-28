#!/bin/sh

set -eu
set -x

/opt/seafile/seafile-server-latest/seafile.sh start >> /var/log/service-seafile.log

while [ 1 ]; do
  sleep 10
done

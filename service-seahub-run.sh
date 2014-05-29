#!/bin/sh

set -eu

# Start in FastCGI mode for serving over TLS via Nginx.
/opt/seafile/seafile-server-latest/seahub.sh start-fastcgi >> /var/log/service-seahub.log

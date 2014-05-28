#!/bin/sh

set -eu
set -x

# Generate the TLS certificate for our Seafile server instance.
SEAFILE_CERT_PATH=/etc/nginx/certs
mkdir -p "$SEAFILE_CERT_PATH"
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=World/L=World/O=seafile/CN=seafile" \
    -keyout "$SEAFILE_CERT_PATH/seafile.key" \
    -out "$SEAFILE_CERT_PATH/seafile.crt"
chmod 600 "$SEAFILE_CERT_PATH/seafile.key"
chmod 600 "$SEAFILE_CERT_PATH/seafile.crt"

# Use some sensible defaults.
if [ -z "$SEAFILE_DOMAIN_NAME" ]; then
    SEAFILE_DOMAIN_NAME=127.0.0.1
fi
if [ -z "$SEAFILE_DOMAIN_PORT" ]; then
    SEAFILE_DOMAIN_PORT=8080
fi

# Enable Seafile in the Nginx configuration.
ln -s /etc/nginx/sites-available/seafile /etc/nginx/sites-enabled/seafile
rm /etc/nginx/sites-enabled/default
sed -i -e "s/%SEAFILE_DOMAIN_NAME%/"$SEAFILE_DOMAIN_NAME"/g" /etc/nginx/sites-available/seafile
sed -i -e "s/%SEAFILE_DOMAIN_PORT%/"$SEAFILE_DOMAIN_PORT"/g" /etc/nginx/sites-available/seafile

# Patch Seahub's configuration to not run in daemonized mode. This is necessary
# for whatever reason to not letting it abort.
## @todo Fix this!
sed -i -e "s/daemon\s*=\s*True/daemon = False/g" \
    /opt/seafile/seafile-server-*/runtime/seahub.conf

# Patch Seafile's CCNet configuration to point to our HTTPS site.
sed -i -e "s/SERVICE_URL\s*=\s*/SERVICE_URL = https://$SEAFILE_DOMAIN_NAME:$SEAFILE_DOMAIN_PORT/g" \
    /opt/seafile/ccnet/ccnet.conf

# Execute Seafile's configuration script for setting up the database.
cd /opt/seafile/seafile-server-*
exec ./setup-seafile-mysql.sh

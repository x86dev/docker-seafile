#!/bin/sh

# Note: Don't set "-u" here; we might check for unset environment variables!
set -e

# Generate the TLS certificate for our Seafile server instance.
SEAFILE_CERT_PATH=/etc/nginx/certs
mkdir -p "$SEAFILE_CERT_PATH"
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=World/L=World/O=seafile/CN=$SEAFILE_DOMAIN_NAME" \
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

# Enable Seafile in the Nginx configuration. Nginx then will serve Seafile
# over HTTPS (TLS).
ln -f -s /etc/nginx/sites-available/seafile /etc/nginx/sites-enabled/seafile
rm -f /etc/nginx/sites-enabled/default
sed -i -e "s/%SEAFILE_DOMAIN_NAME%/"$SEAFILE_DOMAIN_NAME"/g" /etc/nginx/sites-available/seafile
sed -i -e "s/%SEAFILE_DOMAIN_PORT%/"$SEAFILE_DOMAIN_PORT"/g" /etc/nginx/sites-available/seafile

# Configure Nginx so that is doesn't show its version number in the HTTP headers.
sed -i -e "s/.*server_tokens.*/server_tokens off;/g" /etc/nginx/nginx.conf

# Patch Seahub's configuration to not run in daemonized mode. This is necessary
# for whatever reason to not letting it abort.
## @todo Fix this!
sed -i -e "s/.*daemon.*=.*/daemon = False/g" \
    /opt/seafile/seafile-server-*/runtime/seahub.conf

# Execute Seafile's configuration script for setting up the MySQL database.
cd /opt/seafile/seafile-server-*
./setup-seafile-mysql.sh

# After configuring Seafile, patch Seafile's CCNet configuration to point to our HTTPS site.
sed -i -e "s/.*SERVICE_URL.*=.*/SERVICE_URL = https:\/\/$SEAFILE_DOMAIN_NAME:$SEAFILE_DOMAIN_PORT/g" \
    /opt/seafile/ccnet/ccnet.conf

# Also patch Seahub's configuration to use HTTPS for all downloads + uploads.
echo "FILE_SERVER_ROOT = 'https://$SEAFILE_DOMAIN_NAME:$SEAFILE_DOMAIN_PORT/seafhttp'" \
    >> /opt/seafile/seahub_settings.py

## @todo Add memcached support!

# Manually run Seafile to trigger the first-run configuration wizard.
./seafile.sh start
./seahub.sh start-fastcgi

# Shut down every again.
cd /opt/seafile/seafile-server-*
./seahub.sh stop
./seafile.sh stop

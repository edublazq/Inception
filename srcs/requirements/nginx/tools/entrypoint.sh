#!/bin/bash

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: environment variable DOMAIN_NAME is undefined." >&2
    exit 1
fi

if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
    echo "Nginx: setting up ssl ...";

    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=wordpress/CN=${DOMAIN_NAME}";

    echo "Nginx: ssl is set up!";
fi

exec "$@"
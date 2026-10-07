FROM debian:bookworm

RUN apt-get update \
	&& apt-get install -y --no-install-recommends nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

COPY ./conf/default /etc/nginx/sites-enabled/default
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
	&& mkdir -p /etc/nginx/ssl /var/www/html \
	&& chown -R www-data:www-data /var/www/html

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

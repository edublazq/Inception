FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	php-fpm \
	php-mysql \
	ca-certificates \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
	&& mkdir -p /run/php \
	&& chmod 755 /run/php

EXPOSE 9000

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/php-fpm8-2", "-F"]

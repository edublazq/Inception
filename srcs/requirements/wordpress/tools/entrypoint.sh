#!/bin/bash

check_env_var() {
    local var_name=$1
    if [ -z "${!var_name}" ]; then
        echo "Error: environment variable $var_name is undefined." >&2
        exit 1
    fi
}

load_and_check_secret() {
    local var_name=$1
    local secret_name=$2

    local secret_path="/run/secrets/$secret_name"

    if [ ! -s "$secret_path" ]; then
        echo "Error: secret file '$secret_name' not found" >&2
        exit 1
    fi
    export "$var_name"=$(cat "$secret_path" | tr -d '\r\n')
}

check_env_var "MYSQL_DATABASE"
check_env_var "MYSQL_USER"
check_env_var "DOMAIN_NAME"
check_env_var "WORDPRESS_TITLE"
check_env_var "WORDPRESS_ADMIN"
check_env_var "WORDPRESS_ADMIN_EMAIL"
check_env_var "WORDPRESS_USER"
check_env_var "WORDPRESS_EMAIL"

load_and_check_secret "MYSQL_PASSWORD" "db_password"
load_and_check_secret "WORDPRESS_ADMIN_PASS" "wp_admin_password"
load_and_check_secret "WORDPRESS_USER_PASS" "wp_user_password"


echo "Verifying MariaDB conexion..."
until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 3
done
echo "MariaDB conexion stablished..."

if [ ! -f ./wp-config.php ]
then
    echo "Installing wordpress..."

    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN}" \
        --admin_password="${WORDPRESS_ADMIN_PASS}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WORDPRESS_USER}" \
        "${WORDPRESS_EMAIL}" \
        --role=author \
        --user_pass="${WORDPRESS_USER_PASS}" \
        --allow-root

    wp theme install twentysixteen --activate --allow-root

    echo "Wordpress instalation complete!"
fi

chown -R www-data:www-data /var/www/html

exec "$@"
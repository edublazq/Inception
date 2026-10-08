#!/bin/bash

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

load_and_check_secret "DB_PASS" "db_password"
load_and_check_secret "DB_ROOT_PASS" "db_root_password"

if [ -z "$MYSQL_DATABASE" ]; then
    echo "Error: environment variable MYSQL_DATABASE is undefined." >&2
    exit 1
fi

if [ -z "$MYSQL_USER" ]; then
    echo "Error: environment variable MYSQL_USER is undefined." >&2
    exit 1
fi

init_db() {
    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --datadir=/var/lib/mysql --skip-networking &

    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p$DB_ROOT_PASS shutdown
}

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "Initializing MariaDB..."
    init_db
fi

exec "$@"
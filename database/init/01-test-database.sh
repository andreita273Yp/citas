#!/bin/sh
# Crea la base de pruebas <MYSQL_DATABASE>_test y otorga acceso al usuario de la aplicación.
# MySQL lo ejecuta automáticamente al inicializar un volumen nuevo; para un volumen existente:
#   docker compose exec mysql sh /docker-entrypoint-initdb.d/01-test-database.sh
set -e
mysql --protocol=socket -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}_test\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}_test\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

#!/usr/bin/env bash
set -euo pipefail

password="$(openssl rand -base64 36 | tr -d '\n' | tr '/+' '_-')"

mysql --batch <<SQL
CREATE USER IF NOT EXISTS 'chuizhi_app'@'localhost' IDENTIFIED BY '${password}';
ALTER USER 'chuizhi_app'@'localhost' IDENTIFIED BY '${password}';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX ON chuizhi_shop.* TO 'chuizhi_app'@'localhost';
FLUSH PRIVILEGES;
SQL

umask 077
cat > /etc/chuizhi-shop.env <<ENV
SPRING_DATASOURCE_URL=jdbc:mysql://127.0.0.1:3306/chuizhi_shop?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai
SPRING_DATASOURCE_USERNAME=chuizhi_app
SPRING_DATASOURCE_PASSWORD=${password}
ENV

chmod 600 /etc/chuizhi-shop.env

#!/bin/bash
set -e

echo "Waiting for master database to become available..."
until mysql -hmysql-master -uroot -prootpass -e "SELECT 1;" &> /dev/null; do
  echo "MySQL master is unavailable - sleeping."
  sleep 2
done

echo "Waiting for master database initialization..."
sleep 10  # Даем время на полную инициализацию мастера

echo "Creating replication user..."
mysql -hmysql-master -uroot -prootpass -e "
  CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED BY 'replpass';
  GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
  FLUSH PRIVILEGES;
"

# Очищаем существующие таблицы на слейве
echo "Dropping existing database if exists..."
mysql -uroot -prootpass -e "DROP DATABASE IF EXISTS db_app;"

# Копируем данные с мастера
echo "Copying data from master..."
mysqldump -hmysql-master -uroot -prootpass --skip-lock-tables --databases db_app > /tmp/master.sql
mysql -uroot -prootpass < /tmp/master.sql

echo "Getting master status..."
master_status=$(mysql -hmysql-master -uroot -prootpass -e "SHOW MASTER STATUS\G")
master_log_file=$(echo "$master_status" | grep 'File' | awk '{print $2}')
master_log_pos=$(echo "$master_status" | grep 'Position' | awk '{print $2}')

echo "Setting up slave..."
mysql -uroot -prootpass -e "
STOP SLAVE;
RESET SLAVE;
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='replpass',
  MASTER_LOG_FILE='$master_log_file',
  MASTER_LOG_POS=$master_log_pos;
START SLAVE;
"

echo "Replication setup complete"
#!/bin/sh

#https://www.postgresql.org/download/linux/debian/
sudo apt install curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt -y install postgresql-16



# установка пароля пользователя postgres через psql
sudo -u postgres psql --command "ALTER USER postgres WITH PASSWORD 'postgres';"

# Создание роли/пользователя 'zabbix' в кластере Postgresql. 
##su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'zabbix\'';"'
##sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres psql --command "CREATE USER zabbix WITH PASSWORD 'zabbix';"

#Создание БД с владельцем zabbix.
##su - postgres -c 'psql --command "CREATE DATABASE zabbix OWNER zabbix;"'
##sudo -u postgres createdb -O zabbix zabbix
sudo -u postgres psql --command "CREATE DATABASE zabbix OWNER zabbix;"

# На хосте Zabbix сервера импортируем начальную схему и данные.
sudo zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

# Настроем базу данных для Zabbix сервера. Отредактируем файл /etc/zabbix/zabbix_server.conf
sudo sed -i 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf
#sudo sed -i 's/Server=127.0.0.1/Server=127.0.0.1,zabbix-vm.ru-central1.internal/g' /etc/zabbix/zabbix_agentd.conf

## далее в web-интерфейсе zabbix
## schema - public
## password - zabbix
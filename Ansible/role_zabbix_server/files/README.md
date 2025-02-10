https://www.zabbix.com/ru/download?zabbix=7.0&os_distribution=debian&os_version=12&components=server_frontend_agent&db=pgsql&ws=apache

# Установите и сконфигурируйте Zabbix для выбранной платформы
# a. Установите репозиторий Zabbix
wget -O /tmp/zabbix.deb https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
sudo dpkg -i /tmp/zabbix.deb
#  в каталоге /etc/apt/sources.list.d/   появятся файлы *.list
sudo apt update

# b. Установите Zabbix сервер, веб-интерфейс и агент
sudo apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# c. Установить postgresql, настроить пользователя postgres, 

# Сначала добавьте репозиторий PostgreSQL, импортируйте ключ подписи репозитория и обновите списки пакетов, как показано на рисунке.
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" >/etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update

# cоздайте базу данных
# После добавления PostgreSQL APT Repository установите сервер PostgreSQL 16 с помощью следующей команды.
sudo apt install postgresql-16

# 2. Установите и запустите сервер базы данных.

# Выполните следующие комманды на хосте, где будет распологаться база данных.
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix

# При автоматизации с помощью bash можно использовать следующие примеры:
# Создание пользователя с помощью psql из-под root
su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'zabbix\'';"'
su - postgres -c 'psql --command "CREATE DATABASE zabbix OWNER zabbix;"'

# На хосте Zabbix сервера импортируйте начальную схему и данные. Вам будет предложено ввести недавно созданный пароль.
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

#  d. Настройте базу данных для Zabbix сервера
# Отредактируйте файл /etc/zabbix/zabbix_server.conf
sudo nano /etc/zabbix/zabbix_server.conf
DBPassword=zabbix

sed -i 's/# DBPassword=/DBPassword=123456789/g' /etc/zabbix/zabbix_server.conf

# e. Запустите процессы Zabbix сервера и агента
# Запустите процессы Zabbix сервера и агента и настройте их запуск при загрузке ОС.

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

# f. Open Zabbix UI web page
# The default URL for Zabbix UI when using Apache web server is http://host/zabbix

# Начинайте пользоваться Zabbix
# См. документацию: Руководство по быстрому запуску

# Добавление Zabbix agent
# в веб-интерфейсе
# Чтобы подключить агент к Zabbix-серверу, перейдите в Configuration > Hosts
# и нажмите на кнопку Create host
# На вкладке Host укажите Host name, Groups и Template. Далее добавьте
# интерфейс Agent и укажите IP машины, где установлен агент
# 
cat /var/log/zabbix/zabbix_agentd.log

# Для автоматизации с помощью bash-скриптов можно использовать команду:
# Меняем адрес сервера в zabbix_agentd.conf
sed -i 's/Server=127.0.0.1/Server=192.168.0.34'/g' /etc/zabbix/zabbix_agentd.conf

# Перезапустите агента: Теперь сервер сможет подключиться к агенту
sudo systemctl restart zabbix-agent

######
root@debian:~# cd /root/signed-modules
root@debian:~/signed-modules# nano ./sign-virtual-box
root@debian:~/signed-modules# ./sign-virtual-box
Signing /lib/modules/6.1.0-25-amd64/misc/vboxdrv.ko
Signing /lib/modules/6.1.0-25-amd64/misc/vboxnetadp.ko
Signing /lib/modules/6.1.0-25-amd64/misc/vboxnetflt.ko
root@debian:~/signed-modules# modprobe vboxdrv 
root@debian:~/signed-modules# modprobe vboxnetflt 
root@debian:~/signed-modules# modprobe vboxnetadp 

######

Запуск wireshark по конкретному интерфейсу
Снятие tcpdump по конкретному интерфейсу и порту

######
## прописывание в source /etc/network/interfaces
allow-hotplug enp0s8
iface enp0s8 inet static
    address 192.168.0.70
    network 192.168.0.0
    netmask 255.255.255.0
    gateway 192.168.0.1

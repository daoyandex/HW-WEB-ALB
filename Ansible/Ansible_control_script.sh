
# 0. Сначала нужно получить публичный адрес бастионного хоста и указать его в файле ~/HW-WEB-ALB/Ansible/inventory.ini
# в блоке 
# [all:vars]
# ansible_ssh_common_args=

# 1. Установка сервера zabbix на zabbix-vm
# 1.1. Запуск ansible-playbook runrole_1_zabbix_server.yml  :
ansible-playbook 1_runrole_zabbix_server.yml
# 1.2. ручное открытие в браузере страницы сервера zabbix и ручная настройка там:
# http://<nat_ip_address_zabbix_server>/zabbix

# 2. Установка агентов zabbix на web-vm-[1,2]
ansible-playbook 2_runrole_web_vm_z_a.yml

# 3. Установка elasticsearch на соответствующую машину
ansible-playbook 3_runrole_elasticsearch_server.yml

# 4. Скрипт копирования elasticsearch credentials на текущую (управляющую) машину
## в каталог ~/HW-WEB-ALB/Ansible/buffer
4_script_scp_elasticsearch_credentials.sh
# elastic_ca_fingerprint.txt
# elastic_passwd.txt

# 5. Установка kibana с пирогами
## с применением elasticsearch credentials в файле настроек /etc/kibana/kibana.yml
ansible-playbook 5_runrole_kibana_server.yml

# 6. Установка filebeat на машины группы alb-web-vm
## с указанием elasticsearch credentials в файле настроек /etc/filebeat/filebeat.yml
ansible-playbook 6_runrole_web_vm_filebeat.yml

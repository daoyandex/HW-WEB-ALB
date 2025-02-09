#!/bin/sh

bufferDIR='/home/user/HW-WEB-ALB/Ansible/buffer'

bastion_host_ip='84.252.130.47'

ssh-keygen -R elasticsearch-server.ru-central1.internal
ssh-keygen -R kibana-server.ru-central1.internal
ssh-keygen -R web-vm-1.ru-central1.internal
ssh-keygen -R web-vm-2.ru-central1.internal

# 1. скопировали на управляющий хост с elasticsearch-server  пароль пользователя elastic
scp -o ProxyJump=yc-user@$bastion_host_ip yc-user@elasticsearch-server.ru-central1.internal:/tmp/elasticsearch/elastic_passwd.txt $bufferDIR
#scp -o ProxyJump=yc-user@$bastion_host_ip yc-user@elasticsearch-server.ru-central1.internal:/tmp/elasticsearch/kibana_system_passwd.txt $bufferDIR

# 2. скопировали на управляющий хост с elasticsearch-server  отпечаток сертификата elastic
scp -o ProxyJump=yc-user@$bastion_host_ip yc-user@elasticsearch-server.ru-central1.internal:/tmp/elasticsearch/elastic_ca_fingerprint_full.txt $bufferDIR

# 3. скопировали на управляющий хост с elasticsearch-server  токен для сервера kibana
scp -o ProxyJump=yc-user@$bastion_host_ip yc-user@elasticsearch-server.ru-central1.internal:/tmp/elasticsearch/elastic_kibana_enrollment_token.txt $bufferDIR
## 4. скопировали на управляющий хост с elasticsearch-server  токен для присоединяемых нод
#scp -o ProxyJump=yc-user@$bastion_host_ip yc-user@elasticsearch-server.ru-central1.internal:/tmp/elasticsearch/elastic_node_enrollment_token.txt $bufferDIR

# 5.  выделим fingerprint без ":"
cat $bufferDIR/elastic_ca_fingerprint_full.txt | sed '1!d' | tr -d ": " | awk -F"=" '{ print $2 }' > $bufferDIR/elastic_ca_fingerprint.txt

# 5. копируем elasticsearch credentials в каталог files роли role_web_vm_filebeat
role_web_vm_filebeat_filesDIR=/home/user/HW-WEB-ZABBIX/Ansible/role_web_vm_filebeat/files

cp $bufferDIR/elastic_passwd.txt $role_web_vm_filebeat_filesDIR
cp $bufferDIR/elastic_ca_fingerprint.txt $role_web_vm_filebeat_filesDIR

# 6. копируем elasticsearch credentials в каталог files роли role_kibana_server
role_kibana_server_filesDIR=/home/user/HW-WEB-ZABBIX/Ansible/role_kibana_server/files

cp $bufferDIR/elastic_passwd.txt $role_kibana_server_filesDIR
#cp $bufferDIR/kibana_system_passwd.txt $role_kibana_server_filesDIR
cp $bufferDIR/elastic_ca_fingerprint.txt $role_kibana_server_filesDIR
cp $bufferDIR/elastic_kibana_enrollment_token.txt $role_kibana_server_filesDIR

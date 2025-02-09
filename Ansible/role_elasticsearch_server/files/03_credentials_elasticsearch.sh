#!/bin/sh

##########################################################################################
# Подготовительные процессы
ES_TMP_FOLDER='/tmp/elasticsearch'
# 1. Переполучим пароль суперпользователя elastic
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password --batch -s -u elastic > $ES_TMP_FOLDER/elastic_passwd.txt

##   запишем в переменные окружения
export ELASTIC_PASSWORD=`cat $ES_TMP_FOLDER/elastic_passwd.txt`
export ELASTIC_KEYSTORE_PASSPHRASE=$ES_TMP_FOLDER/elastic_passwd.txt
export ES_PATH_CONF=/etc/elasticsearch
export ES_HOME=/usr/share/elasticsearch

echo "export ELASTIC_PASSWORD=$ELASTIC_PASSWORD" | sudo tee -a ~/.bashrc
echo "export ES_HOME=/usr/share/elasticsearch" | sudo tee -a ~/.bashrc
echo "export ES_PATH_CONF=/etc/elasticsearch"  | sudo tee -a ~/.bashrc

source .bashrc

# 2. Получим отпечаток сертификата CA elasticsearch из /etc/elasticsearch/certs/http_ca.crt
sudo openssl x509 -fingerprint -sha256 -in /etc/elasticsearch/certs/http_ca.crt > $ES_TMP_FOLDER/elastic_ca_fingerprint_full.txt

# 3. Подготовим enrollment-token для передачи на сервер kibana
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana > $ES_TMP_FOLDER/elastic_kibana_enrollment_token.txt
##########################################################################################
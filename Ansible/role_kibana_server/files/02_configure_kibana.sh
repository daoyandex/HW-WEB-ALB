#!/bin/sh
KIBANA_CONFIG=/etc/kibana/kibana.yml
PATH_KIBANA_TMP_FOLDER=/tmp/kibana

#sudo sed -i -E 's/^#elasticsearch.username: "kibana_system"/elasticsearch.username: "kibana_system"/g' $PATH_KIBANA_CONFIG
#sudo sed -i -E 's/^#elasticsearch.hosts: [\"http://localhost:9200\"]/elasticsearch.hosts: [\"https://elasticsearch-server.ru-central1.internal:9200\"]/g'$PATH_KIBANA_CONFIG
#sed -i -E 's/^#network.host: 192.168.0.1/network.host: 0.0.0.0/g' $PATH_KIBANA_CONFIG
#sed -i -E 's/^#http.port: 9200/http.port: 9200/g' $PATH_KIBANA_CONFIG

KIBANA_ENROLLMENT_TOKEN=`cat $PATH_KIBANA_TMP_FOLDER/elastic_kibana_enrollment_token.txt`

sed -i -E 's/^#server.port: 5601/server.port: 5601/g' $KIBANA_CONFIG
sed -i -E 's/^#server.host: "localhost"/server.host: "0.0.0.0"/g' $KIBANA_CONFIG

sudo /usr/share/kibana/bin/kibana-setup --enrollment-token $KIBANA_ENROLLMENT_TOKEN


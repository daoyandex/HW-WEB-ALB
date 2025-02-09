#!/bin/sh

# донастройка конфигурационного файла /etc/filebeat/filebeat.yml
# - указание данных из elastic_ca_fingerprint, elastic_passwd
FILEBEAT_CONFIG_FOLDER=/etc/filebeat
FILEBEAT_CONFIG=$FILEBEAT_CONFIG_FOLDER/filebeat.yml

FILEBEAT_TMP_FOLDER=/tmp/filebeat

ES_PASSWORD=`cat $FILEBEAT_TMP_FOLDER/elastic_passwd.txt`
#ES_PASSWORD='"'$(<$FILEBEAT_TMP_FOLDER/elastic_passwd.txt)'"'

ES_FINGERPRINT=`cat $FILEBEAT_TMP_FOLDER/elastic_ca_fingerprint.txt`
#ES_FINGERPRINT='"'$(<$FILEBEAT_TMP_FOLDER/elastic_ca_fingerprint.txt)'"'

## блок регулировки Filebeat modules
#sudo sed -i -E 's/reload.enabled: false/reload.enabled: true/g' $FILEBEAT_CONFIG

# блок регулировки хоста Kibana
sudo sed -i -E 's/#host: "localhost:5601"/host: "http:\/\/kibana-server:5601"/g' $FILEBEAT_CONFIG

# блок регулировки хоста Elasticsearch
sudo sed -i -E 's/localhost:9200/https:\/\/elasticsearch-server:9200/g' $FILEBEAT_CONFIG
#sudo sed -i -E 's/https:\/\/elasticsearch-server:9200/http:\/\/elasticsearch-server:9200/g' $FILEBEAT_CONFIG

# блок регулировки протокола
sudo sed -i -E 's/#protocol: \"http\"/protocol: \"https\"/g' $FILEBEAT_CONFIG
sudo sed -i -E 's/protocol: \"http\"/protocol: \"https\"/g' $FILEBEAT_CONFIG
sudo sed -i -E 's/#protocol: \"https\"/protocol: \"https\"/g' $FILEBEAT_CONFIG

# блок регулировки аутентификации
sudo sed -i -E 's/#username: \"elastic\"/username: \"elastic\"/g' $FILEBEAT_CONFIG
sudo sed -i -E "s/#password: \"changeme\"/password: $ES_PASSWORD\n  ssl:\n    enabled: true\n    ca_trusted_fingerprint: $ES_FINGERPRINT/g" $FILEBEAT_CONFIG


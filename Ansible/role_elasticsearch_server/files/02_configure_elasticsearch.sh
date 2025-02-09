#!/bin/sh
PATH_ES_CONFIG=/etc/elasticsearch/elasticsearch.yml
sudo sed -i -E 's/^#cluster.name: my-application/cluster.name: my-ES-cluster/g' $PATH_ES_CONFIG
sudo sed -i -E 's/^#network.host: 192.168.0.1/network.host: 0.0.0.0/g' $PATH_ES_CONFIG
sudo sed -i -E 's/^#http.port: 9200/http.port: 9200/g' $PATH_ES_CONFIG
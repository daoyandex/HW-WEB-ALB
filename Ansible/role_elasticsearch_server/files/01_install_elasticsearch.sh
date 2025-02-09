#!/bin/sh
# ssh -J yc-user@<bastion-ip> yc-user@<host-ip> -v

DIRECTORY='/tmp/elasticsearch'
echo $DIRECTORY

if [ ! -d "$DIRECTORY" ]; then
  sudo mkdir -p -m 755 $DIRECTORY
  echo "$DIRECTORY did not exist and was made."
else
  echo "$DIRECTORY exists."
fi

#wget -O $DIRECTORY/elasticsearch.deb https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.17.0-amd64.deb
# установим deb-пакет elasticsearch
sudo dpkg -i $DIRECTORY/elasticsearch.deb
sudo systemctl daemon-reload


# памяка по удалению ES
#sudo dpkg --remove elasticsearch
#sudo apt-get remove --purge elasticsearch
#sudo rm -rf /etc/elasticsearch
#sudo rm -rf /var/lib/elasticsearch


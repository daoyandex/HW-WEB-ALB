#!/bin/sh
# ssh -J yc-user@84.201.158.119 yc-user@172.16.20.34 -v

DIRECTORY='/tmp/kibana'
echo $DIRECTORY

if [ ! -d "$DIRECTORY" ]; then
  sudo mkdir -p -m 755 $DIRECTORY
  echo "$DIRECTORY did not exist and was made."
else
  echo "$DIRECTORY exists."
fi

# памяка по удалению
sudo dpkg --remove kibana
sudo apt-get remove --purge kibana
sudo rm -rf /etc/kibana
sudo rm -rf /var/lib/kibana

# wget -O $DIRECTORY/kibana.deb https://artifacts.elastic.co/downloads/kibana/kibana-8.17.0-amd64.deb
# установим deb-пакет kibana
sudo dpkg -i $DIRECTORY/kibana.deb
sudo systemctl daemon-reload





#!/bin/sh

DIRECTORY='/tmp/filebeat'
echo $DIRECTORY

if [ ! -d "$DIRECTORY" ]; then
  sudo mkdir -p -m 755 $DIRECTORY
  echo "$DIRECTORY did not exist and was made."
else
  echo "$DIRECTORY exists."
fi

wget -O $DIRECTORY/filebeat.deb https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.17.0-amd64.deb
sudo dpkg -i $DIRECTORY/filebeat.deb
sudo apt update

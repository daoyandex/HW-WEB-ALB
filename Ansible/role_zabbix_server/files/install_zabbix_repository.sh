#!/bin/sh

DIRECTORY='/tmp/zabbix_repo_info'
echo $DIRECTORY

if [ ! -d "$DIRECTORY" ]; then
  sudo mkdir -p -m 755 $DIRECTORY
  echo "$DIRECTORY did not exist and was made."
else
  echo "$DIRECTORY exists."
fi

wget -O $DIRECTORY/zabbix_debian12_all.deb https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
sudo chmod 0777 $DIRECTORY/zabbix_debian12_all.deb 
sudo dpkg -i $DIRECTORY/zabbix_debian12_all.deb
sudo apt update
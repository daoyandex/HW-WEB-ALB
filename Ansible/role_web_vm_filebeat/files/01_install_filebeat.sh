#!/bin/sh
# ssh -J yc-user@84.201.158.119 yc-user@172.16.20.34 -v

DIRECTORY='/tmp/filebeat'
echo $DIRECTORY

if [ ! -d "$DIRECTORY" ]; then
  sudo mkdir -p -m 755 $DIRECTORY
  echo "$DIRECTORY did not exist and was made."
else
  echo "$DIRECTORY exists."
fi

# установим deb-пакет filebeat
if [ -f "$DIRECTORY/filebeat.deb" ]; then
  sudo dpkg -i $DIRECTORY/filebeat.deb
  sudo systemctl daemon-reload
  
  echo "filebeat.deb has been installed."
else
  echo "filebeat.deb has NOT been installed."
fi


#! /bin/bash
sudo apt-get update
sudo apt-get install apache2 -y
sudo systemctl reload apache2
sudo rm -rf /var/www/html/index.html
sudo echo "hello everyone $HOSTNAME" >> /var/www/html/index.html
EOF
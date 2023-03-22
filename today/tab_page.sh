#! /bin/bash
sudo apt-get update
sudo apt-get install apache2 -y
sudo systemctl reload apache2
sudo rm -rf /var/www/html/index.html
sudo mkdir -p /var/www/html/tab
sudo echo "hello everyone this is tab apge $HOSTNAME" >> /var/www/html/tab/index.html
EOF
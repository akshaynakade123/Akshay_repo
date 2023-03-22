locals {
  user_data = <<EOF
#! /bin/bash
sudo apt update
sudo apt install openjdk-8-jre-headless -y
sudo apt-get update
sudo apt install apache2 -y
sudo cat "this is for trial" >> /var/http/index.html
sudo systemctl start apache2
sudo systemctl enable apache2
EOF
}
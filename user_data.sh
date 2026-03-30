#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Sao Paulo app tier is alive" > /var/www/html/index.html
echo "OK" > /var/www/html/health

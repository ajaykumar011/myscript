
#!/bin/bash
# This script works only with new installation and tested with Centos 6.5
#variables define here..
mv /etc/localtime /etc/localtime.bak #This is not tested
ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime #This is not tested
servername="$(hostname):80"
myip=$(curl -s http://myip.dnsomatic.com | grep -P '[\d.]')
#Installation begins here..
yum update -y 
yum install vim epel-release net-tools -y
alias vi=vim
echo "Your Centos Release"
cat /etc/redhat-release

yum -y groupinstall "Development Tools"
yum -y install httpd httpd-devel mysql-server php php-devel php-common php-mysql mod_ssl openssl
for r in httpd mysqld; do service $r start; done  
for s in httpd mysqld; do chkconfig $s on; done 

yum search php-

echo "<html><body><h1>Server ready </h1></body></html>" > /var/www/html/index.html 
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

perl -pi -e "s/www.example.com:80/$servername/g" /etc/httpd/conf/httpd.conf
service httpd restart

sh dbcreatec6.sh

yum -y install phpmyadmin
perl -pi -e "s/127.0.0.1/$myip/g" /etc/httpd/conf.d/phpMyAdmin.conf
echo "phpMyadmin Installed..."
echo " "
echo "Server [$servername] status....."
echo "================================================"
curl -I -L http://$servername
echo "Server WAN IP Address " $myip >> /tmp/scriptinfo.txt
echo "Server Host name " $(hostname) >> /tmp/scriptinfo.txt
echo "-----------------------------------------------------------" >> /tmp/scriptinfo
clear
clear
echo "Now you will configure the rest ................."
echo "Script information file is there in /tmp/scriptinfo.txt ................."
echo "========================================================================="
clear
clear
cat /tmp/scriptinfo.txt
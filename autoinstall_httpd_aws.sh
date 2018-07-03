
#!/bin/bash
#This script works with Amazon Linux 2. You need to first login as root via 'sudo -s' command. you also need to install git first.
#variables define here..

#sudo -s # login as root to execute these commands.

mv /etc/localtime /etc/localtime.bak #This is not tested
ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime #This is not tested
servername="$(hostname):80"
myip=$(curl -s http://myip.dnsomatic.com | grep -P '[\d.]')
#Installation begins here..
yum update -y 
yum install vim epel-release net-tools -y
alias vi=vim
echo "Your Amazon AMI Version"
cat /etc/system-release
echo "Your OS Release information"
cat /etc/os-release
uname -a

yum -y groupinstall "Development Tools"
yum -y install httpd httpd-devel php php-common php-mysql mariadb-server mariadb mod_ssl openssl

for r in httpd mariadb; do systemctl start $r; done  
for r in httpd mariadb; do systemctl status $r; done  
for r in httpd mariadb; do systemctl enable $r; done  

yum search php-

echo "<html><body><h1>Server ready </h1></body></html>" > /var/www/html/index.html 
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

perl -pi -e "s/www.example.com:80/$servername/g" /etc/httpd/conf/httpd.conf
service httpd restart

sh dbcreatecaws.sh

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
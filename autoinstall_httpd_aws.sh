
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
alias vi=vim
echo "Your Amazon AMI Version"
cat /etc/system-release
cat /sys/hypervisor/uuid
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
# phpMyAdmin is a web-based database management tool that you can use to view and edit the MySQL databases on your EC2 instance"

yum install php-mbstring.x86_64 php-zip.x86_64 -y
service httpd restart
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm -rf phpMyAdmin-latest-all-languages.tar.gz
service mariadb restart
# you can browse the site from this link http://my.public.dns.amazonaws.com/phpMyAdmin

perl -pi -e "s/127.0.0.1/$myip/g" /etc/httpd/conf.d/phpMyAdmin.conf
echo "phpMyadmin Installed..."
echo " "
echo "Server [$servername] status....."
echo "================================================"
curl -I -L http://$servername
echo "Server WAN IP Address " $myip 
echo "Server Host name " $(hostname) 
echo "-----------------------------------------------------------" 
echo "Version Information of Installed LAMP"

httpd -v
#Server version: Apache/2.4.33 ()
php -v
#PHP 5.4.16 (cli) (built: Jun 19 2018 19:05:33)
mysql --version
#mysql  Ver 15.1 Distrib 5.5.56-MariaDB, for Linux (x86_64) using readline 5.1
cat /etc/system-release
#Amazon Linux 2

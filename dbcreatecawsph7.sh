#!/usr/bin/expect -f
# set your variables here

#we are generating databasename and username from /dev/urandom command. 
dbname=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '');

#we are generating username from openssl command
dbuser=$(openssl rand -base64 12 | tr -dc A-Za-z | head -c 8 ; echo '')

#Openssl is another way to generating 64 characters long password)
#dbpass=$(openssl rand -hex 8); #It generates max 16 digits password we can also use this for all above process.

dbpass=$(openssl rand -base64 8);

MYSQL_PASS=$(openssl rand -base64 12); #this is root password of mysql of 12 characters long.

webroot="/var/www/html"
yum install expect -y
systemctl restart mariadb
systemctl enable mariadb
expect -f - <<-EOF
  set timeout 1
  spawn mysql_secure_installation
  expect "Enter current password for root (enter for none):"
  send -- "\r"
  expect "Set root password?"
  send -- "y\r"
  expect "New password:"
  send -- "${MYSQL_PASS}\r"
  expect "Re-enter new password:"
  send -- "${MYSQL_PASS}\r"
  expect "Remove anonymous users?"
  send -- "y\r"
  expect "Disallow root login remotely?"
  send -- "y\r"
  expect "Remove test database and access to it?"
  send -- "y\r"
  expect "Reload privilege tables now?"
  send -- "y\r"
  expect eof
EOF
echo "------------------------DB setup done-----------------------------------"
Q1="CREATE DATABASE IF NOT EXISTS $dbname;"
Q2="GRANT USAGE ON *.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';"
Q3="GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost;"
Q4="FLUSH PRIVILEGES;"
Q5="SHOW DATABASES;"  
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}"
  
mysql -uroot -p$MYSQL_PASS -e "$SQL"
echo "----------------Database processing done successfully-------------------"

cd $webroot
curl -O https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz
cd wordpress
cp -rf . ..
cd ..
rm -R wordpress
#chown -R apache:apache $webroot
#chmod -R 775 $webroot
cp wp-config-sample.php wp-config.php
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php

#Setting permission for ec2-user and apache
usermod -a -G apache ec2-user
id ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

#Cleaning work
rm latest.tar.gz
rm -rf index.html
echo "=========================================================="
echo "Wordpress Installation is completed."
echo "=========================================================="

echo "-----------------Script Output-----------------------" 
echo "::::::Date_Time:::::::" $(date +%F_%R) 
echo "MySQL Password.." $MYSQL_PASS 
echo "DB User & Host : " $dbuser"@"$(hostname) 
echo "DB Name: " $dbname 
echo "DB Password: " $dbpass

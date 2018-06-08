#!bin/bash
# This script is tested on Ubuntu server. Make sure you have curl and wget installed...
# Copy this script to the webroot..
# set your variables here
clear
echo "Your system information:"
echo "----------------------------------------------------------------------------------------------------------"
uname -a 
echo "----------------------------------------------------------------------------------------------------------"
echo "Your current working directory: "
pwd
servername="$(hostname):80"
myip=$(curl -s http://myip.dnsomatic.com | grep -P '[\d.]')
echo "=========================================================================================================="
echo "Welcome to Wordpress Installation...."
echo "=========================================================================================================="
echo "This script automatically create a datbase and downloads files from wordpress.org"
echo "Let me show your current directory permissions set: "
echo "----------------------------------------------------------------------------------------------------------"
user=$(ls -ld | awk '{print $3}')
group=$(ls -ld | awk '{print $4}')
echo "Your current directory username and groupname is below:"
echo $user:$group
echo "----------------------------------------------------------------------------------------------------------"
#read -p "Enter your apache username (don't leave this blank):" user
#read -p "Enter your apache groupname (don't leave this blank):" group

read -p "Enter your mysql root password :" MYSQL_PASS
read -p "Do your have database created already [y/n] :" dbexist

if [ "$dbexist" = "y" ] ; then

	echo "Great................................."
	echo "Enter your database details to get started..."
	echo "Database Host: localhost (automatically selected)"
	read -p "Database Name (don't leave blank) :" dbname
	read -p "Database User (don't leave blank):" dbuser
	read -p "Database Password (don't leave blank) :" dbpass
else
	echo "It seems that you have no database.. don't worry we would create this for you"
 	sleep 2s
	echo "Database automatic setup has been started now...."
	myip=$(curl -s http://myip.dnsomatic.com | grep -P '[\d.]');

	#we are generating databasename and username from /dev/urandom command. 
	dbname=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '')

	#dbpass=$(openssl rand -hex 8); #It generates max 16 digits password 
	dbuser=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '')

	#Openssl is another way to generating 64 characters long password)
	
	dbpass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo '')

	# MYSQL_PASS=$(openssl rand -base64 12); #this is root password of mysql of 12 characters long automatically generated..
	echo "------------------------DB setup done-----------------------------------"
Q1="CREATE DATABASE IF NOT EXISTS $dbname;"
Q2="GRANT USAGE ON *.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';"
Q3="GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost;"
Q4="FLUSH PRIVILEGES;"
Q5="SHOW DATABASES;"	
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}"
  
mysql -uroot -p$MYSQL_PASS -e "$SQL"
fi
echo "-------------------------------------------------DB setup done-------------------------------------------------"

# End of datbase setup both manual and automatic..
sleep 2s
echo "--------------------------------------------Database processing done successfully------------------------------"
echo "Downloading latest wordpress site for you"
curl -O https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz
cd wordpress
cp -rf . ..
cd ..
rm -R wordpress
sudo chown -R $user:$group *
#sudo chmod -R 775 *
#create uploads folder and set permissions
mkdir -p wp-content/uploads
chmod 775 wp-content/uploads

echo "----------------------------------Wordpress Configuration is started--------------------------------------------" 

sleep 2s
# Setting up configuration file of wordpress
cp wp-config-sample.php wp-config.php
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

echo "-----------------------------Wordpress Configuration is processed successfully-----------------------------------" 

echo "::::::Date_Time:::::::" $(date +%F_%R)
# echo "MySQL Password.." $MYSQL_PASS
echo "DB Name: " $dbname
echo "DB User & Host : " $dbuser"@"$(hostname)
echo "DB Password: " $dbpass
#Getting server information..
echo "================================================================================================================"
echo "Server [$servername] status....."
echo "================================================================================================================"
echo " "
curl -I -L http://$servername
echo "Server WAN IP Address " $myip
echo "Server Host name " $(hostname)

#clean up work..
rm latest.tar.gz
rm wp-install.sh
echo "================================================================================================================"
echo "Wordpress Installation is completed."
echo "Thank you"
echo "================================================================================================================"

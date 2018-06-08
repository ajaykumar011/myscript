#!/bin/bash


MYSQL_LOGIN='-h localhost -u root --password=centos5'

function press_enter
{
    echo ""
    echo -n "Press Enter to continue   "
    read
    clear
}


function optimize_ALL_DB
{
for db in $(echo "SHOW DATABASES;" | mysql $MYSQL_LOGIN | grep -v -e "Database" -e "information_schema")
do
        TABLES=$(echo "USE $db; SHOW TABLES;" | mysql $MYSQL_LOGIN |  grep -v Tables_in_)
        echo "Switching to database $db"
        for table in $TABLES
        do
                echo -n " * Optimizing table $table ... "
                echo "USE $db; OPTIMIZE TABLE $table" | mysql $MYSQL_LOGIN  >/dev/null
                echo "done."
        done
done
}


function ShowAllDB
{
echo "List of Databases : " 
count1=0
for db2 in $(echo "SHOW DATABASES;" | mysql $MYSQL_LOGIN | grep -v -e "Database" -e "information_schema" -e "mysql" -e "performance_schema")
do 
	echo -n $db2; 
	echo " "
	count1=$((count1+1))
done
echo "Total number of Databases are: " $count1
}


function optimize_One_DB
{
echo ""
echo -n "Enter DB Name: "
read singleDB
db=$singleDB

RESULT=`mysql $MYSQL_LOGIN -e "SHOW DATABASES" | grep -Fo $singleDB`

#echo "You enter Database name: "  $RESULT;
if [ "$RESULT" == $singleDB ]; then
    echo "Database " $singleDB " exist"
	  TABLES=$(echo "USE $db; SHOW TABLES;" |  mysql $MYSQL_LOGIN  |   grep -v Tables_in_)
        echo "Switching to database $db"
        for table in $TABLES
        do
                echo -n " * Optimizing table $table ... "
                echo "USE $db; OPTIMIZE TABLE $table" |  mysql $MYSQL_LOGIN >/dev/null
                echo "done."
        done
	
else
    echo "Database does not exist"
fi
  	
}

function Apache_status_menu
{

selection1=
until [ "$selection1" = "9" ]; do
	echo ""
	clear
    echo "Apache Status:" $(Apache_status)
	echo ""
	echo "1 - Reload Apache"
    echo "2 - Stop Apache"
	echo "3 - show Apache status"
	echo "4 - Start Apache "
    echo "9 - Return to main menu"
	echo ""
    echo -n "Enter selection: "
    read selection1
    echo ""
    case $selection1 in
        1 ) echo `service httpd reload`; press_enter ;;
        2 ) echo `service httpd stop`; press_enter ;;
		3 ) echo `service httpd status`; press_enter ;;
		4 ) echo `service httpd start`; press_enter ;;
        9 ) main_menu; press_enter ;;
        * ) echo "Please enter 1, 2, 3 , 4 or 9"; press_enter
    esac
done
}


function Apache_status
{
check1="$(pgrep -f httpd)"
check2="$(service httpd status | grep -E is[^not]running)"

[[ -n $check1 && -n $check2 ]] && echo "httpd is running!" || { echo "httpd is dead!"; }

echo "" 
echo -n

}


function Mysql_status
{
check1="$(pgrep -f mysqld)"
check2="$(service mysqld status | grep -E is[^not]running)"

[[ -n $check1 && -n $check2 ]] && echo "mysqld is running!" || { echo "mysqld is dead!"; }

}

function Mysql_status_menu
{
selection2=
until [ "$selection2" = "9" ]; do
	echo ""
	clear
    echo "Mysql Server Status:" $(Mysql_status)
	echo ""
	echo "1 - Optimize ALL Databases"
    echo "2 - Optimize Single Databases"
    echo "3 - Show Databses"
	echo "4 - Restart MySql"
    echo "5 - Stop MySql"
	echo "6 - Show MySql Server status"
	echo "7 - Start MySql "
    echo "9 - Return to main menu"
	echo ""
    echo -n "Enter selection: "
    read selection2
    echo ""
    case $selection2 in
		1 ) optimize_ALL_DB; press_enter ;;
        2 ) optimize_One_DB; press_enter ;;
		3 ) ShowAllDB; press_enter ;;
		4 ) echo `service mysqld restart`; press_enter ;;
        5 ) echo `service mysqld stop`; press_enter ;;
		6 ) echo `service mysqld status`; press_enter ;;
		7 ) echo `service mysqld start`; press_enter ;;
		9 ) main_menu; press_enter ;;
        * ) echo "Please enter 1, 2, 3 , 4 or 9"; press_enter
    esac
done


}

function hdd_info
{
echo " Disk information"
echo `df -lh`

}


function server_update
{ 
echo "Updating system..."
echo `yum update -y`

}

function main_menu 
{
selection=
until [ "$selection" = "0" ]; do
	clear
    echo "Program"
	echo ""
	echo "Mysql Server Status:" $(Mysql_status)
	echo "MySQL Version:"  $((mysql --version) | cut -c1-31)
	echo "" 
	echo "Apache Status:" $(Apache_status)
	echo $(( httpd -v) | cut -c1-30 )
	echo ""
	echo "PHP Version:" $(( php -v ) | cut -c5-20)
	echo "" 
	echo "Host Name:" $(hostname)
	echo "Host IP:" $(ifconfig  eth0 | grep "inet addr" | cut -c21-34)
	echo "" 
	echo "" 
	echo "" 
	echo "1 - Show Mysql Server Status"
	echo "2 - Show  Apache Service Status"
	echo "3 - Hard Disk Usage Info"
	echo "4 - Update  "
    echo "0 - exit program"
    echo ""
	echo "" 
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
        #1 ) optimize_ALL_DB; press_enter ;;
        #2 ) optimize_One_DB; press_enter ;;
		#3 ) ShowAllDB; press_enter ;;
		1 ) Mysql_status_menu; press_enter;;
		2 ) Apache_status_menu; press_enter;;
		3 ) hdd_info; press_enter;;
		4 ) server_update; press_enter;;
        0 ) exit ;;
        * ) echo "Please enter 1, 2, 3, 4 or 0"; press_enter
    esac
done
       
}

main_menu
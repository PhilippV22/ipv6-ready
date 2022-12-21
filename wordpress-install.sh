#!/bin/bash

#name of the wordpress folder
folder="wordpress"

#ask the user for the mysql database password
echo -n "Enter MySQL user password: "
read pass

#mysql command to create database 
mysqlcmd="CREATE DATABASE wordpress_db;"

#create the wp database
mysql -u root -p$pass -e "$mysqlcmd"

#download wordpress
wget -P $folder https://wordpress.org/latest.tar.gz
tar -zxf $folder/latest.tar.gz -C $folder/

#copy the folder content to html
cp -ar $folder/* /var/www/html

#delete the tar and folder
rm -rf $folder

#permission
chown -R www-data:www-data /var/www/html

#WordPress config file
cd /var/www/html
mv wp-config-sample.php wp-config.php

#replace the database parameters in wp-config file
sed -i "s/database_name_here/wordpress_db/g" wp-config.php
sed -i "s/username_here/root/g" wp-config.php
sed -i "s/password_here/$pass/g" wp-config.php

echo "WordPress is ready."
echo "Go to your website for WordPress setup."

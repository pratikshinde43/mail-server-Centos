

#importing parameters file
# domain_name= $1
# ip_address= $2

echo domain_name= $1
echo ip_address= $2




#starting the mysql file
systemctl start mysqld

#checking it is active or not
# resuilt= systemctl status mysqld | grep 'active (running)'

# if [ -z "$result" ]
# then
# 	echo "mysql not started"
# else
# 	echo "mysql started"
# fi

#creating the  dir mailserver
mkdir -p /etc/ssl/mailserver

#changing the directory to mailserver
cd /etc/ssl/mailserver 

#creating the certificates
openssl genrsa -out server.key 1024

chmod 600 server.key

openssl req -new -key server.key -out server.csr -subj "/C=IN/ST=MH/L=Pune/O=''/OU=IT/CN=$1"

openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt

cat server.key server.crt > server.pem 

chmod 600 server.pem

#making the dir postfixadmin
mkdir -p /var/www/vhosts/postfixadmin

cd

#downloading the postfixadmin
wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.93/postfixadmin-2.93.tar.gz

#unzipping the postadmoinfix file 
tar -xzvf postfixadmin-2.93.tar.gz

#moving the files to folder
mv postfixadmin-2.93/* /var/www/vhosts/postfixadmin/

#giving the apache permission
chown -R apache:apache /var/www/vhosts/postfixadmin/

#moving the conf file
mv ~/postfixadmin.conf /etc/httpd/conf/postfixadmin.conf

#restarting the file
service httpd restart
echo "------------------x---------------------x-----------------------------x-----------------"

#include the posfixadmin file
echo "Include /etc/httpd/conf/postfixadmin.conf" >> /etc/httpd/conf/httpd.conf

#changing the parameters form conf file
sed -i 's/VirtualHost 167.172.114.219:80/VirtualHost '$2':80/g' /etc/httpd/conf/postfixadmin.conf

#changing the email name
sed -i 's/ServerAdmin\(.*\)/ServerAdmin admin@'$1'/g' /etc/httpd/conf/postfixadmin.conf

#changing the server-name 
sed -i 's/ServerName\(.*\)/ServerName '$1'/g' /etc/httpd/conf/postfixadmin.conf


#restarting the file
service httpd restart

#starting the apache
systemctl start httpd


echo "Creating the database"

#taking temp password
result=$(awk '/root@localhost/{print $NF}' /var/log/mysqld.log)

#echo $result
#echo "$mysql_password"

#setting new password
mysql -u root -p"$result" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Dyna@123';"

echo "password changed"

# Creating mail database
mysql -u root -p"Dyna@123" --connect-expired-password -e "CREATE database mail;"
echo "------------------x---------------------x-----------------------------x-----------------"

#Making dir vmail
mkdir /var/vmail

#adding user
useradd vmail

#givinh 500 permission 
usermod -u 500 vmail
groupmod -g 500 vmail


#giving mail permisson to vmail
chown -R vmail:mail /var/vmail

#moving to the root
cd  

#restarting the apache
systemctl restart httpd

#getting dovecot file
wget https://www.dropbox.com/s/59pq4uil3326x2g/postfix_%26_dovecot_Backup.zip?dl=0

#unzipping the file
unzip -o postfix_\&_dovecot_Backup.zip?dl=0

#going in dir
cd postfix_\&_dovecot_Backup

#copying the files to etc/postfix
yes | cp postfix_backup/* /etc/postfix/
yes | cp -rvf dovecot_backup/dovecot/* /etc/dovecot/

#restarting the postfix and dovecot
service postfix restart
service dovecot restart


#adding hostname to main.cf
sed -i 's/myhostname = delfastpro.net/myhostname = '$1'/g' /etc/postfix/main.cf


#restarting the postfix and dovecot
service postfix restart
service dovecot restart

echo "------------------x---------------------x-----------------------------x-----------------"

cd 
echo "moving the my.cnf to /etc"
# echo "adding insql file"
sed -n -i 'p;5a sql_mode = "ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"' /etc/my.cnf 

echo "moving the config.inc.php file..."
mv -f config.inc.php /var/www/vhosts/postfixadmin/


# mv --force my.cnf /etc/

systemctl restart mysqld
echo "------------------x---------------------x-----------------------------x-----------------"

#pass the postfix password and get th hashkey
curl --insecure -X POST --data "form=setuppw&setup_password=Test123&setup_password2=Test123&submit=Generate+password+hash" "http://$1/setup.php" > response.html
postfix_token=`cat response.html | sed -rn "s/.*\['setup_password'\] = '(.*)';<\/pre><\/div>/\1/p"`

echo "------------------x---------------------x-----------------------------x-----------------"
echo "your token is: $postfix_token"
echo "------------------x---------------------x-----------------------------x-----------------"

#adding hash key to the config.inc.php
sed -i 's/changeme/'$postfix_token'/g' /var/www/vhosts/postfixadmin/config.inc.php 

#passing the email and password of the admin
curl --insecure -X POST --data "form=createadmin&setup_password=Test123&username=admin@$1&password=Test123&password2=Test123&submit=Add+Admin" "http://$1/setup.php" > response.html
sed -rn 's/.*(The admin .*@.* has been added)\!.*/\1/p' response.html 
sed -rn 's/.*(The admin .*@.* has been added)\!.*/\1/p' response.html 
mv -f mysql_virtual_alias_maps.cf /etc/postfix
mv -f mysql_virtual_domains_maps.cf /etc/postfix
mv -f mysql_virtual_mailbox_limit_maps.cf /etc/postfix
mv -f mysql_virtual_mailbox_maps.cf /etc/postfix

sleep 5

systemctl restart postfix





echo "--------------------------------------------------------------------------------------------"
echo "Server is set"
echo "password is Test123"
echo "--------------------------------------------------------------------------------------------"
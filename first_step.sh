
domain_name= $1
ip_address= $2


echo domain_name= $1
echo ip_address= $2


#for update
yum -y update

#Update Basec packages
yum -y groupinstall 'Base'

#Make sure all ports are opened
iptables -n -L


#Make sure selimux disabled
sestatus

#Go to Line SELINUX= and change it with 'Disabled" and Save changes
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config



#Check hostname
hostname

#Server momory
free -m

#arddisk usage
df -h

#Check Resolve Conf
cat /etc/resolv.conf

#Check Redhat version
cat /etc/redhat-release

#check server uname
uname -a

#Install Essential Packages
yum -y install httpd dovecot dovecot-mysql php php-* --skip-broken

#Install my-sql server by checking repository mysql 5.7
yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

#Install my-sql server
yum -y install mysql-community-server

yum -y install epel-release

yum -y install epel-release

#installing imap
yum -y install php-imap*



#restart
reboot

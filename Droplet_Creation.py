#!/usr/local/bin/python3.7
import digitalocean
from datetime import datetime
import os
import time
import  sys
import logging
import paramiko

class Droplet:
	logging.basicConfig(level=logging.INFO)
	# logging.basicConfig(filename='Droplet_Creation.log', filemode='w', level=logging.INFO)
	def __init__(self,droplet_name,tag_name,api_key):
		self.api_key = api_key
		self.manager = digitalocean.Manager(token=self.api_key)
		self.droplet_tag_name = []
		self.droplet_name=droplet_name
		self.tag = tag_name
		self.droplet_tag_name.append(tag_name)
		
	def create_droplet(self):
		if self.checking_droplet() is True:
			self.ip_address = self.fetching_ip_address()
			self.start_installation()

		else:
			self.keys = self.manager.get_all_sshkeys()
			print("Creating the droplet")
			
			try:
				droplet = digitalocean.Droplet(token=self.api_key,
								   	name=self.droplet_name,
								   	region='nyc1',  # New York 2
								   	image='centos-7-x64',  # Ubuntu 14.04 x64
								   	size_slug='512mb',
									ssh_keys=self.keys,# 512MB
								   	backups=False,
								   	tags=self.droplet_tag_name

								   )
				droplet.create()
				time.sleep(30)
				print("----Droplet Created--------")
				print('Ip_address of ' + self.droplet_name + ' Tag name is ' + self.tag + ' ' + self.fetching_ip_address())
				self.droplet_tag_name.clear()
				self.ip_address=self.fetching_ip_address()
				print("-------Droplet Created---------")
				time.sleep(4)
				logging.info("Starting installation")
				#self.start_installation()
				
					
					
					self.start_installation()
					
				
	def start_installation(self):
		key = paramiko.RSAKey.from_private_key_file("/var/www/html/list.pem")
		conn = paramiko.SSHClient()
		conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		print("connecting")
		conn.connect(hostname=self.fetching_ip_address(), username="root", pkey=key, timeout=450)
		print("connected")
		#os.system("sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config")
		listOfFile = os.listdir("/var/www/html/Python/")
		files = []
		for entry in listOfFile:
			files.append(entry)
		print(files)
		logging.info(files)
		
		
		sftp = conn.open_sftp()
		for file in files:
			sftp.put(file, "root")
			print(file + "file transfered")
			logging.info(file + "file transfered")
		sftp.close()


		stdin, stdout, stderr = conn.exec_command("sh first_step.sh")
		for line in stdout:
			logging.info(line.rstrip())
		print(stdout.read())
		logging.info(stdout.read())
		conn.close()
		time.sleep(30)
		
		#key = paramiko.RSAKey.from_private_key_file("/var/www/html/list.pem")
		c_2 = paramiko.SSHClient()
		c_2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		print("connecting")
		logging.info("conecting 2nd session")
		c_2.connect(hostname=self.fetching_ip_address(), username="root", pkey=key, timeout=450)
		print("connected")
		logging.info("2nd session connected")
		
		stdin, stdout, stderr = c_2.exec_command("sh second_step.sh"+" "+self.droplet_name+" "+self.fetching_ip_address())
		for line in stdout:
			logging.info(line.rstrip())
		print(stdout.read())
		logging.info(stdout.read())

		
	def checking_droplet(self):
		droplet_data = self.manager.get_data('https://api.digitalocean.com/v2/droplets?tag_name='+self.tag)
		if len(droplet_data['droplets']) > 0:
			if droplet_data['droplets'][0]['name'] == self.droplet_name:
				print("Change the name and tag")
				logging.info("Change the name and tag")
				print('Ip_address of ' + " Droplet " + self.droplet_name + ' and Tag name ' + self.tag + " " + '=' + self.fetching_ip_address())
				logging.info('Ip_address of ' + " Droplet " + self.droplet_name + ' and Tag name ' + self.tag + " " + '=' + self.fetching_ip_address())
				#self.creating_ip_address_file(self.fetching_ip_address())
			return True
		else:
			return False
		
		
	def fetching_ip_address(self):
		droplet_data = self.manager.get_data('https://api.digitalocean.com/v2/droplets?tag_name='+self.tag)
		if len(droplet_data) > 0:
			data = droplet_data['droplets'][0]['networks']['v4']
			if len(data) > 0:
				ip_address = droplet_data['droplets'][0]['networks']['v4'][0]['ip_address']
				#self.creating_ip_address_file(ip_address)
				return  ip_address
		else:
			return "not found"



droplet_name = input("Enter the Droplet name")
print(droplet_name)
tag = input("Enter the tag name")
print(tag)
api_key =input("Enter the Digital Ocean API key")
print(api_key)



a = Droplet(droplet_name=droplet_name,tag_name=tag,api_key=api_key)

a.create_droplet()









#!/bin/bash
sudo yum update -y
sudo yum install java-11* -y
sudo install wget curl -y

## Configure Tomcat 

cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.9/bin/apache-tomcat-10.1.9.tar.gz
# unzip tomcat binary
tar -xvzf apache-tomcat-10.1.9 
# Rename for simplicity 
mv apache-tomcat-10.1.9 tomcat
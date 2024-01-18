#!/bin/bash
sudo yum update -y
sudo yum install java-17* -y
sudo install wget git curl -y

## install Start And Enable Docker
sudo yum install docker -y
sudo systemctl start docker 
sudo systemctl enable docker.service
sudo chmod 777  /var/run/docker.sock
sudo usermod -aG docker ec2-user
sudo systemctl restart docker


## Path For Deployment
mkdir -p /app/qa/deploy

## Configure Tomcat 
cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.9/bin/apache-tomcat-10.1.9.tar.gz
# unzip tomcat binary
tar -xvzf apache-tomcat-10.1.9 
# Rename for simplicity 
mv apache-tomcat-10.1.9 tomcat
#!/bin/bash

sudo apt update 

## install Start And Enable Docker 
sudo apt install docker.io -y
sudo systemctl start docker 
sudo systemctl enable docker.service
sudo chmod 777 /var/run/docker.sock

#Add ubuntu user to docker group ==> allow ubuntu user to execute docker commands

sudo usermod -aG docker ubuntu
sudo systemctl restart docker

docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
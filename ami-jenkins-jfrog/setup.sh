#!/bin/bash

# trivy Security scan tool install
sudo yum update -y
sudo yum update -y
sudo yum install wget -y
wget https://github.com/aquasecurity/trivy/releases/download/v0.53.0/trivy_0.53.0_Linux-64bit.tar.gz

tar zxvf trivy_*.tar.gz
sudo mv trivy /usr/local/bin/


#!/bin/bash

echo "===================== TRIVY INSTALLATION ======================"

sudo yum install wget -y
wget https://github.com/aquasecurity/trivy/releases/download/v0.53.0/trivy_0.53.0_Linux-64bit.tar.gz

tar zxvf trivy_*.tar.gz
sudo mv trivy /usr/local/bin/
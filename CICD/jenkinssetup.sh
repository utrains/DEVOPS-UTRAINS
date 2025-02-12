#!/bin/bash

sudo yum update -y

# trivy Security scan tool install

sudo yum install wget -y
wget https://github.com/aquasecurity/trivy/releases/download/v0.53.0/trivy_0.53.0_Linux-64bit.tar.gz

tar zxvf trivy_*.tar.gz
sudo mv trivy /usr/local/bin/

## Helm install 

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


#!/bin/bash -x

#### Autor : Utrains
#### Date : 12-29-2022

sudo yum update -y

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade -y

## install Start And Enable Docker
sudo yum install docker -y
sudo service docker start 
sudo systemctl enable docker.service

sudo chmod 777  /var/run/docker.sock


## Install aws cli
sudo yum install aws-cli -y

## install Git
sudo yum install git -y
yum install unzip -y

## Install Java 11:
#sudo amazon-linux-extras install java-openjdk11 -y

sudo yum install java-11* -y
## Install Jenkins then Enable the Jenkins service to start at boot :
sudo yum install jenkins -y
sudo systemctl enable jenkins

## Start Jenkins as a service:
sudo systemctl start jenkins

## Display Initial Jenkins Password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword



#------------------------------------------------------------------------------------#
# This part of the script installs maven, then configures the environment variables. #
#------------------------------------------------------------------------------------#

# Download mavan to /tmp directory then untar it on /opt after create a symbolic link
wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-3.9.5-bin.tar.gz -C /opt
sudo mv /opt/apache-maven-3.9.5 /opt/maven

JAVA_PATH=`find /usr/lib/jvm/java-11* | head -n 3 | grep 64`
export JAVA_HOME=$JAVA_PATH
export M2_HOME=/opt/maven
export M2=$M2_HOME/bin
export PATH=${JAVA_HOME}:${M2_HOME}:${M2}:${PATH}

### Configure the path variable 
cat > /tmp/maven.sh << EOF
# Confifuration file for java and maven
#export JAVA_HOME=$JAVA_PATH
#export M2_HOME=/opt/maven
#export M2=$M2_HOME/bin
export PATH=${JAVA_HOME}:${M2_HOME}:${M2}:${PATH}
EOF

sudo cp /tmp/maven.sh /etc/profile.d/
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh


#------------------------------------------------------------------------------------#
# This part of the script installs  Install Terraform.                               #
#------------------------------------------------------------------------------------#

# Install jq package for get Terraform version
sudo yum install jq -y

# Get the latest version of Terraform from the releases page
TERRAFORM_VERSION=1.6.5
# The get the Latest version of Terraform, you can execute this command : 
# curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M .current_version

# Download and install Terraform
sudo curl -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/

# Clean up downloaded files
rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

#------------------------------------------------------------------------------------#
# This part of the script to install python3 and all necessary moduls.               #
#------------------------------------------------------------------------------------#

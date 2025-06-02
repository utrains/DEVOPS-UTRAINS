#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Date : 12 FEB 2025                                                                                                    #
# Description : This script file allows you to configure : host server server,  configure splunk server log directories #
# Write By : Hermann90 for Utrains                                                                                      #                                                                                             #
#-----------------------------------------------------------------------------------------------------------------------#

GREEN_COLOR_SUCCESS='\033[1;32m'
CYAN_COLOR_STARTING='\033[1;36m'
RED_COLOR_FAILLED='\033[1;31m'
COLOR_RESET_OF='\033[0m'

JAVA_AND_MAVEN_PATH_FILE=java_path.sh
PROFILES_USERS_DIR=/etc/profile.d

echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> JJENKINS INSTALLATION <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                                    #                                                                                             

confirm_installation_step () {
	if [ $? -eq 0 ]; then
		echo "${GREEN_COLOR_SUCCESS} >>>>>>>>>>>>>>>> $1 : $2 SUCESS <<<<<<<<<<<<<<<<"
		echo -e "${GREEN_COLOR_SUCCESS} $2 is installed Successfully ${COLOR_RESET_OF}"
		echo ">>>>>>>>>>>>>>>> Thanks to configure $2 <<<<<<<<<<<<<<<<"
	else
		echo "${RED_COLOR_FAILLED} **************** $1 : Service $2 Failled ****************"
		echo "${RED_COLOR_FAILLED} Sorry, we can't continue with this installation. Please check why the $2 service has not been installed."
		exit 1
	fi
}

if [ -f $PROFILES_USERS_DIR/$JAVA_AND_MAVEN_PATH_FILE ]; then
    echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> RELOADING JAVA ENV FOR JFROG <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"
	source $PROFILES_USERS_DIR/$JAVA_AND_MAVEN_PATH_FILE    
	echo echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> JAVA PATH IS : $JAVA_HOME  <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                               #                                                                                             
fi

sudo yum update -y

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade -y

## Install aws cli ==> jenkins to run aws commands.
sudo yum install aws-cli -y

## install Git  ==> jenkins to run git commands
sudo yum install git -y
yum install unzip -y

#sudo yum install java-17* -y
## Install Jenkins then Enable the Jenkins service to start at boot :
sudo yum install jenkins -y
sleep 10
sudo systemctl enable jenkins

## Start Jenkins as a service:
sudo systemctl start jenkins

#Add jenkins user to docker group  ==> allow jenkins user to execute docker commands

sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user
sudo systemctl restart jenkins



#------------------------------------------------------------------------------------#
# This part of the script installs  Install Terraform.                               #
#------------------------------------------------------------------------------------#

# Install jq package for get Terraform version
sudo yum install jq -y

# Get the latest version of Terraform from the releases page
TERRAFORM_VERSION=1.6.5
# The get the Latest version of Terraform, you can execute this command : 

# Download and install Terraform
sudo curl -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/

# Clean up downloaded files
rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

#------------------------------------------------------------------------------------#
# This part of the script to install python3 and all necessary moduls.               #
#------------------------------------------------------------------------------------#
sudo yum install python3 -y
pip3 install requests
pip3 install boto3

## Display Initial Jenkins Password
Jenkins_password=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

echo "${Jenkins_password}" > /home/ec2-user/initial_jenkins_pwd.txt

systemctl status jenkins | grep "running"
confirm_installation_step "Step " "START JENKINS"
exit 0
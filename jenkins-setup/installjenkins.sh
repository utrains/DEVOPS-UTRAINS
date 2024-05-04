#!/bin/bash -x

#### Autor : Utrains Team
#### Date : 12-29-2022
### Modified november 2023 by Prof

sudo yum update -y

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade -y

## Install aws cli ==> jenkins to run aws commands.
sudo yum install aws-cli -y

## install Git  ==> jenkins to run git commands
sudo yum install git -y
yum install unzip -y

## Install Java 17:
#sudo amazon-linux-extras install java-openjdk11 -y

sudo yum install java-17* -y
## Install Jenkins then Enable the Jenkins service to start at boot :
sudo yum install jenkins -y
sudo systemctl enable jenkins

## Start Jenkins as a service:
sudo systemctl start jenkins

## install Start And Enable Docker 
sudo yum install docker -y
sudo service docker start 
sudo systemctl enable docker.service
sudo chmod 777  /var/run/docker.sock

#Add jenkins user to docker group  ==> allow jenkins user to execute docker commands

sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


#------------------------------------------------------------------------------------#
# This part of the script Dowload and untar maven, using tar xf ...                  #
#------------------------------------------------------------------------------------#

# Download mavan to /tmp directory then untar it on /opt after create a symbolic link
wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-3.9.5-bin.tar.gz -C /opt
sudo mv /opt/apache-maven-3.9.5 /opt/maven

#------------------------------------------------------------------------------------#
# This part of the script installs  sonar-scanner tool                               #
#------------------------------------------------------------------------------------#
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip

sudo mv sonar-scanner-4.8.0.2856-linux/ /opt/sonar-scanner


# Clean up downloaded files
rm -rf sonar-scanner-cli-4.8.0.2856-linux.zip

#-----------------------------------------------------------------------------------------------------#
# This part of the script configures the JAVA, MAVEN And SONAR_SCANNER environment variables          #
#-----------------------------------------------------------------------------------------------------#
JAVA_PATH=`find /usr/lib/jvm/java-17* | head -n 3 | grep 64`
export JAVA_HOME=$JAVA_PATH
export M2_HOME=/opt/maven
export M2=$M2_HOME/bin
export SONAR_RUNNER_HOME=/opt/sonar-scanner
export PATH=${JAVA_HOME}:${M2_HOME}:${M2}:${SONAR_RUNNER_HOME}:${PATH}

### Configure the path variable 
cat > /tmp/maven.sh << EOF
# Confifuration file for java and maven
export JAVA_HOME=$JAVA_PATH
export M2_HOME=/opt/maven
export M2=$M2_HOME/bin
export SONAR_RUNNER_HOME=${SONAR_RUNNER_HOME}
export PATH=${JAVA_HOME}:${M2_HOME}:${M2}:${SONAR_RUNNER_HOME}:${PATH}
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
sudo yum install python3 -y
pip3 install requests
pip3 install boto3
pip3 install virtualenv. 

## Display Initial Jenkins Password
Jenkins_password=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

echo "The initial jenkins passowrd is: ${Jenkins_password}"

exit(0)

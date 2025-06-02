#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Step 0 : Functions Declaration                                                                                        #
# Description : This section is dedicated to the Declaration of functions that will be used later in our scripts.       #
#-----------------------------------------------------------------------------------------------------------------------#
# This function takes a step as parameter (exampe etap 1), then the service name (example docker), 
# then confirms whether or not the service has been installed.
# 
# Write By : Hermann90 for Utrains                                                                                      #                                                                                             

GREEN_COLOR_SUCCESS='\033[1;32m'
CYAN_COLOR_STARTING='\033[1;36m'
RED_COLOR_FAILLED='\033[1;31m'
COLOR_RESET_OF='\033[0m'

JAVA_AND_MAVEN_PATH_FILE=java_path.sh
PROFILES_USERS_DIR=/etc/profile.d

# JFROG Variables
ARTIFACTORY_NAME=jfrog-artifactory
ARTIFACTORY_LOCATION=/opt/jfrog-artifactory/app/bin

echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> JFROG INSTALLATION <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                                    #                                                                                             
                                                                                     

confirm_installation_step () {
	if [ $? -eq 0 ]; then
		echo "${GREEN_COLOR_SUCCESS} >>>>>>>>>>>>>>>> $1 : $2 SUCESS <<<<<<<<<<<<<<<<"
		echo -e "${GREEN_COLOR_SUCCESS} $2 is installed Successfully ${COLOR_RESET_OF}"
		echo ">>>>>>>>>>>>>>>> Thanks to configure $2 <<<<<<<<<<<<<<<<"
	else
		echo "${RED_COLOR_FAILLED} **************** $1 : Service $2 Failled **************** ${COLOR_RESET_OF}"
		echo "${RED_COLOR_FAILLED} Sorry, we can't continue with this installation. Please check why the $2 service has not been installed. ${COLOR_RESET_OF}"
		exit 1
	fi
}

if [ -f $PROFILES_USERS_DIR/$JAVA_AND_MAVEN_PATH_FILE ]; then
    echo -e "${CYAN_COLOR_STARTING} >>>>>>>>>>>>>>>> RELOADING JAVA ENV FOR JFROG <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"
	source $PROFILES_USERS_DIR/$JAVA_AND_MAVEN_PATH_FILE    
	echo echo -e "${CYAN_COLOR_STARTING} >>>>>>>>>>>>>>>> JAVA PATH IS : $JAVA_HOME  <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                               #                                                                                             
fi

# Step 1 : Install Java 11, and config JAVA_HOME environment variable
echo -e "${CYAN_COLOR_STARTING} ---------------- STEP 1 : JFROG DAEMOND CONFIG ---------------- ${COLOR_RESET_OF}"



echo "${CYAN_COLOR_STARTING} ---------------- STEP 1 : CONFIG JFROG AS SERVICE---------------- ${COLOR_RESET_OF}"
cat <<EOF | sudo tee /etc/systemd/system/artifactory.service
[Unit]
Description=JFrog Artifactory OSS
After=network.target

[Service]
Type=forking
ExecStart=$ARTIFACTORY_LOCATION/artifactory.sh start
ExecStop=$ARTIFACTORY_LOCATION/artifactory.sh stop
User=artifactory
Group=artifactory
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

ls /etc/systemd/system/ | grep artifactory.service
# validate the jfrog service configuration
confirm_installation_step "STEP 1" "CONFIG JFROG AS SERVICE"

echo -e "${CYAN_COLOR_STARTING} ---------------- STEP 2 : DOWNLOAD JFROG ---------------- ${COLOR_RESET_OF}"
wget https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/7.68.20/jfrog-artifactory-oss-7.68.20-linux.tar.gz
tar -xvf jfrog-artifactory-oss-7.68.20-linux.tar.gz

sudo mv artifactory-oss-7.68.20 /opt/jfrog-artifactory
rm -f jfrog-artifactory-oss-7.68.20-linux.tar.gz

sudo groupadd artifactory
sudo useradd -g artifactory artifactory
sudo chown -R artifactory:artifactory /opt/jfrog-artifactory

# Sarting JFROG Service
sudo systemctl daemon-reload

sudo systemctl stop artifactory

# STEP 3 : Start Jfrog, enable it and check if the Jfrog service is up and ruinning 
echo -e "${CYAN_COLOR_STARTING} ---------------- STEP 3 : STARTING JFROG ---------------- ${COLOR_RESET_OF}"
sudo systemctl start artifactory 
sudo systemctl enable artifactory

systemctl status artifactory | grep "running"
# Confirm whether Step 4 has been successfully completed before proceeding.
confirm_installation_step "Step 3" "START JFROG"

# End ok the installation
echo "${GREEN_COLOR_SUCCESS} >>>>>>>>>>>>>>>> SUCESS JFROG INSTALLATION <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"
echo "${GREEN_COLOR_SUCCESS} ---------------- End of JFROG installation in our server ---------------- ${COLOR_RESET_OF}"
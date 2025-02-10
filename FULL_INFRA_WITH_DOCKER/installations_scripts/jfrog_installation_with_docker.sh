#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Date : 27 SEP 2024                                                                                                    #
# Description : We're writing this script to install a JFROG server from a Docker image on an amazon linux 2 machine.   #
# Write By : Hermann90 for Utrains                                                                                      #                                                                                             #
#-----------------------------------------------------------------------------------------------------------------------#

# Global Variable Declaration
JFROG_IMAGE="artifactory-oss"
JFROG_VERSION="latest"
JFROG_CONTAINER_NAME="artifactory"

#-----------------------------------------------------------------------------------------------------------------------#
# Step 0 : Functions Declaration                                                                                        #
# Description : This section is dedicated to the Declaration of functions that will be used later in our scripts.       #
#-----------------------------------------------------------------------------------------------------------------------#
# This function takes a step as parameter (exampe etap 1), then the service name (example docker), 
# then confirms whether or not the service has been installed.
confirm_installation_step () {
	if [ $? -eq 0 ]; then
		echo ">>>>>>>>>>>>>>>> $1 : $2 SUCESS <<<<<<<<<<<<<<<<"
		echo "$2 is installed Successfully"
		echo ">>>>>>>>>>>>>>>> Thanks to configure $2 <<<<<<<<<<<<<<<<"
	else
		echo "**************** $1 : Service $2 Failled ****************"
		echo " Sorry, we can't continue with this installation. Please check why the $2 service has not been installed."
		exit 1
	fi
} 


# Step 2 : Pull Jfrog image
# ---> Download Artifactory Docker image from docker.bintray.io
# ---> Create Data Directory on host system to ensure data used on container is persistent.
# Image location is in Jfrog : https://docker.bintray.io/ui/repos/tree/General/registry/repositories/jfrog/artifactory-oss
sudo docker pull docker.bintray.io/jfrog/$JFROG_IMAGE:$JFROG_VERSION
sudo chmod 666 /var/run/docker.sock
docker images | grep $JFROG_IMAGE

# Confirm whether step 2 has been successfully completed before proceeding.
confirm_installation_step "STEP 2" "Pull JFROG Image"
sudo mkdir -p /jfrog/$JFROG_CONTAINER_NAME
sudo chown -R 1030 /jfrog/




# Step 3 : Start JFrog Artifactory container
sudo docker run --name $JFROG_CONTAINER_NAME -d -p 8081:8081 -p 8082:8082 \
-v /jfrog/$JFROG_CONTAINER_NAME:/var/opt/jfrog/$JFROG_CONTAINER_NAME docker.bintray.io/jfrog/$JFROG_IMAGE:$JFROG_VERSION
docker ps | grep $JFROG_IMAGE:$JFROG_VERSION

# Confirm whether step 3 has been successfully completed before proceeding.
confirm_installation_step "STEP 3" "Start JFROG Container"

# Step 4 : Run Artifactory as a service.
# ---> create artifactory.service 
# ---> move the file created in /etc/systemd/system/
# ---> Reload the service, then start Artifactory container with systemd.
cat <<EOF | sudo tee artifactory.service
[Unit]
Description=Setup Systemd script for Artifactory Container
After=network.target
[Service]
Restart=always
ExecStartPre=-/usr/bin/docker kill artifactory
ExecStartPre=-/usr/bin/docker rm artifactory
ExecStart=/usr/bin/docker run --name artifactory -p 8081:8081 -p 8082:8082 \
  -v /jfrog/artifactory:/var/opt/jfrog/artifactory \
  docker.bintray.io/jfrog/artifactory-oss:latest
ExecStop=-/usr/bin/docker kill artifactory
ExecStop=-/usr/bin/docker rm artifactory
[Install]
WantedBy=multi-user.target
EOF

sudo mv artifactory.service /etc/systemd/system/
#Reload Systemd
sudo systemctl daemon-reload
sudo systemctl start artifactory
sudo systemctl enable artifactory
#Check whether Artifactory Service is running
systemctl status artifactory | grep "running"
# Confirm whether Step 4 has been successfully completed before proceeding.
confirm_installation_step "Step 4" "artifactory"

# End ok the installation
echo ">>>>>>>>>>>>>>>> SUCESS JFROG INSTALLATION <<<<<<<<<<<<<<<<"
echo "End of JFROG installation in a docker image"
#!/bin/bash

echo " ================= DOCKER INSTALLATION PROCESS ================="

#-----------------------------------------------------------------------------------------------------------------------#
# Step 0 : Functions Declaration                                                                                        #
# Description : This section is dedicated to the Declaration of functions that will be used later in our scripts.       #
#-----------------------------------------------------------------------------------------------------------------------#
# This function takes a step as parameter (exampe etap 1), then the service name (example docker), 
# then confirms whether or not the service has been installed.
confirm_installation_step () {
	if [ $? -eq 0 ]; then
        echo "$(tput setaf 2) ################################################################# $(tput sgr 0)"
		echo "$(tput setaf 2) >>>>>>>>>>>>>>>> $1 : $2 SUCESS <<<<<<<<<<<<<<<<$(tput sgr 0)"
        echo "$(tput setaf 2) $2 is installed Successfully $(tput sgr 0)"
        echo "$(tput setaf 2) >>>>>>>>>>>>>>>> Thanks to configure $2 <<<<<<<<<<<<<<<< $(tput sgr 0)"
        echo "$(tput setaf 2) ################################################################# $(tput sgr 0)"

	else
        echo "$(tput setaf 1) **************** $1 : Service $2 Failled **************** $(tput sgr 0)"
		echo "$(tput setaf 2) Sorry, we can't continue with this installation. Please check why the $2 service has not been installed. $(tput sgr 0)"
		exit 1
	fi
} 

sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
systemctl status docker | grep "running"

# Confirm whether step 1 has been successfully completed before proceeding.
confirm_installation_step "STEP 1" "Docker"
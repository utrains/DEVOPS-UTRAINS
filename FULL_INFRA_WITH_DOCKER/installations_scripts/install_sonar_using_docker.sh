#!/bin/bash

GREEN_COLOR_SUCCESS='\033[1;32m'
CYAN_COLOR_STARTING='\033[1;36m'
RED_COLOR_FAILLED='\033[1;31m'
COLOR_RESET_OF='\033[0m'

JAVA_AND_MAVEN_PATH_FILE=java_path.sh
PROFILES_USERS_DIR=/etc/profile.d

# JFROG Variables
ARTIFACTORY_NAME=jfrog-artifactory
ARTIFACTORY_LOCATION=/opt/jfrog-artifactory/app/bin

echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> SONARQUBE INSTALLATION <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                                    #                                                                                             
                                                                                     

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

docker pull sonarqube:lts-community
echo "================= START SONARQUBE WITH DOCKER ======================="
docker run -d --restart=on-failure --name sonar -p 9000:9000 sonarqube:lts-community
sleep 5
docker ps | grep sonar
confirm_installation_step "STEP 2" "SONARQUBE"
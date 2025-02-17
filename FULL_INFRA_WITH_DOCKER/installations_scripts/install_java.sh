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

echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> JAVA, MAVEN AND SONAR-SCANNER  INSTALLATION <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                                    #                                                                                             

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

MAVEN_PATH=/opt/maven
SONAR_SCANNER_PATH=/opt/sonar-scanner



# Step 1 : Install Java 17, and config JAVA_HOME environment variable
echo -e "${CYAN_COLOR_STARTING}---------------- STEP 1 : JAVA INSTALLATION ---------------- ${COLOR_RESET_OF}"

sudo yum install java-17* -y


echo -e "${CYAN_COLOR_STARTING}---------------- STEP 2 : MAVEN INSTALLATION ---------------- ${COLOR_RESET_OF}"


# Download mavan to /tmp directory then untar it on /opt after create a symbolic link
wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-3.9.5-bin.tar.gz -C /opt
sudo mv /opt/apache-maven-3.9.5 $MAVEN_PATH


echo -e "${CYAN_COLOR_STARTING}---------------- STEP 3 : SONAR-SACANNER INSTALLATION ---------------- ${COLOR_RESET_OF}"
#------------------------------------------------------------------------------------#
# This part of the script installs  sonar-scanner tool                               #
#------------------------------------------------------------------------------------#
sudo rm -rf /opt/sonar* || echo "No sonar-scanner found"
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip

sudo mv -f sonar-scanner-4.8.0.2856-linux/ $SONAR_SCANNER_PATH


# Clean up downloaded files
rm -rf sonar-scanner-cli-4.8.0.2856-linux.zip

echo -e "${CYAN_COLOR_STARTING}>>>>>>>>>>>>>>>> JAVA, MVN AND SONAR-SCANNER ENV VARIABLE CONFIG <<<<<<<<<<<<<<<< ${COLOR_RESET_OF}"                                                                                    #                                                                                             

JAVA_PATH=`find /usr/lib/jvm/java-17* | head -n 3 | grep 64`
export JAVA_HOME=$JAVA_PATH
export M2_HOME=$MAVEN_PATH
export M2=$M2_HOME/bin
export SONAR_RUNNER_HOME=$SONAR_SCANNER_PATH
export PATH=${JAVA_HOME}:${M2_HOME}:${M2}:${SONAR_RUNNER_HOME}:${PATH}



### Configure the path variable 
cat > /tmp/$JAVA_AND_MAVEN_PATH_FILE << EOF
# Confifuration file for java path
export JAVA_HOME=$JAVA_PATH
export M2_HOME=$MAVEN_PATH
export PATH=${JAVA_HOME}:${PATH}
EOF

sudo cp /tmp/$JAVA_AND_MAVEN_PATH_FILE $PROFILES_USERS_DIR/
sudo chmod +x $PROFILES_USERS_DIR/$JAVA_AND_MAVEN_PATH_FILE
source $PROFILES_USERS_DIR/$JAVA_AND_MAVEN_PATH_FILE

echo $JAVA_HOME | grep java
# Confirm whether step 1 has been successfully completed before proceeding.
confirm_installation_step "STEP 1" "JAVA"

# Confirmation MAVEN Installation
mvn -version | grep maven
confirm_installation_step "STEP 2" "MAVEN"

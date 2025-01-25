#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Step 0 : Functions Declaration                                                                                        #
# Description : This section is dedicated to the Declaration of functions that will be used later in our scripts.       #
#-----------------------------------------------------------------------------------------------------------------------#
# This function takes a step as parameter (exampe etap 1), then the service name (example docker), 
# then confirms whether or not the service has been installed.
# 
# Write By : Hermann90 for Utrains                                                                                      #                                                                                             

echo ">>>>>>>>>>>>>>>> CONFIG JFROG <<<<<<<<<<<<<<<<"

#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Step 0 : Functions Declaration                                                                                        #
# Description : This section is dedicated to the Declaration of functions that will be used later in our scripts.       #
#-----------------------------------------------------------------------------------------------------------------------#
# This function takes a step as parameter (exampe etap 1), then the service name (example docker), 
# then confirms whether or not the service has been installed.
# 
# Write By : Hermann90 for Utrains                                                                                      #                                                                                             

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

# Step 1 : Install Java 11, and config JAVA_HOME environment variable
echo "---------------- STEP 1 : JAVA INSTALLATION ----------------"
sudo yum install java-11-amazon-corretto-headless -y
JAVA_PATH=`find /usr/lib/jvm/java-11* | head -n 3 | grep 64`
export JAVA_HOME=$JAVA_PATH
export PATH=${JAVA_HOME}:${PATH}



### Configure the path variable 
cat > /tmp/java_path.sh << EOF
# Confifuration file for java path
export JAVA_HOME=$JAVA_PATH
export PATH=${JAVA_HOME}:${PATH}
EOF

sudo cp /tmp/java_path.sh /etc/profile.d/
sudo chmod +x /etc/profile.d/java_path.sh
source /etc/profile.d/java_path.sh

echo $JAVA_HOME | grep java
# Confirm whether step 1 has been successfully completed before proceeding.
confirm_installation_step "STEP 1" "JAVA"

echo "---------------- STEP 2 : CONFIG JFROG AS SERVICE----------------"
cat <<EOF | sudo tee artifactory.service
[Unit]
Description=JFROG Artifactory
After=syslog.target network.target

[Service]
Type=forking

Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_PID=/opt/artifactory/artifactory-oss-6.9.6/run/artifactory.pid"
Environment="CATALINA_HOME=/opt/artifactory/artifactory-oss-6.9.6/tomcat"
Environment="CATALINA_BASE=/opt/artifactory/artifactory-oss-6.9.6/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/opt/artifactory/artifactory-oss-6.9.6/bin/artifactory.sh start
ExecStop=/opt/artifactory/artifactory-oss-6.9.6/bin/artifactory.sh stop

User=artifactory
Group=artifactory
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

ls | grep artifactory.service
# validate the jfrog service configuration
confirm_installation_step "STEP 4" "CONFIG JFROG AS SERVICE"


# STEP 3 : create artifactory user and his home directory
echo "---------------- STEP 3 : ADD JFROG USER----------------"
sudo useradd -r -m -U -d /opt/artifactory -s /bin/false artifactory 

confirm_installation_step "STEP 3" "ADD JFROG USER"


sudo cp artifactory.service /etc/systemd/system/artifactory.service

sudo systemctl daemon-reload

sudo systemctl stop artifactory

sudo rm -rf /opt/jfrog* /opt/artifactory*

sudo wget -q https://jfrog.bintray.com/artifactory/jfrog-artifactory-oss-6.9.6.zip

sudo unzip -q jfrog-artifactory-oss-6.9.6.zip -d /opt/artifactory

sudo chown -R artifactory: /opt/artifactory/*

sudo rm -rf jfrog-artifactory-oss-6.9.6.zip


# STEP 4 : Start Jfrog, enable it and check if the Jfrog service is up and ruinning 
echo "---------------- STEP 4 : STARTING JFROG ... ----------------"
echo "*****Starting Artifactory Service"
sudo systemctl start artifactory 
sudo systemctl enable artifactory

#Check whether Artifactory Service is running
systemctl status artifactory | grep "running"
# Confirm whether Step 4 has been successfully completed before proceeding.
confirm_installation_step "Step 4" "artifactory"

# End ok the installation
echo ">>>>>>>>>>>>>>>> SUCESS JFROG INSTALLATION <<<<<<<<<<<<<<<<"
echo "End of JFROG installation in our server"
echo
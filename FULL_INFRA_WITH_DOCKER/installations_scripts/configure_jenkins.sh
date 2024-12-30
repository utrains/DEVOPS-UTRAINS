#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------------#
# Date : 27 SEP 2024                                                                                                    #
# Description : This script file allows you to configure : host server server,  configure splunk server log directories #
# Write By : Hermann90 for Utrains                                                                                      #                                                                                             #
#-----------------------------------------------------------------------------------------------------------------------#

echo ">>>>>>>>>>>>>> JENKINS CONFIG <<<<<<<<<<<<<<<"
docker pull jenkins/jenkins
docker run --name jenkins-blueocean --restart=on-failure --detach -p 8080:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home jenkins/jenkins
PASSWORD=`docker exec -it -w / jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword`
echo $PASSWORD > initial_jenkins_pwd.txt
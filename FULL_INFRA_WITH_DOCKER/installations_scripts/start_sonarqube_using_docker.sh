#!/bin/bash

echo "================= START SONARQUBE WITH DOCKER ======================="
docker run -d --restart=on-failure --name sonar -p 9000:9000 sonarqube:lts-community

# check if the container is running

docker ps | grep sonar

if [ $? -eq 0 ]; then
    echo "Sonarqube container is running"
else
    echo "Sonarqube container is not running"
    exit 1
fi  
#!/bin/bash

echo "================= START SONARQUBE WITH DOCKER ======================="
docker run -d --restart=on-failure --name sonar -p 9000:9000 sonarqube:lts-community
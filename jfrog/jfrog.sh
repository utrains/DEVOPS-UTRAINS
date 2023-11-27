#!/bin/bash



# Installing necessary packages
echo "\n\n*****Installing necessary packages"
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get install -y default-jre unzip > /dev/null 2>&1

# Creating the jfrog service file for systemd

cat <<EOF | sudo tee artifactory.service
[Unit]
Description=JFROG Artifactory
After=syslog.target network.target

[Service]
Type=forking

Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
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

# Configuring Artifactory as a Service
echo "*****Configuring Artifactory as a Service"
sudo useradd -r -m -U -d /opt/artifactory -s /bin/false artifactory 2>/dev/null
sudo cp artifactory.service /etc/systemd/system/artifactory.service
sudo systemctl daemon-reload 1>/dev/null


# Downloading JFROG Artifactory 6.9.6 version to OPT folder
echo "*****Downloading JFROG Artifactory 6.9.6 version"
sudo systemctl stop artifactory > /dev/null 2>&1
cd /opt 
sudo rm -rf jfrog* artifactory*
sudo wget -q https://jfrog.bintray.com/artifactory/jfrog-artifactory-oss-6.9.6.zip
sudo unzip -q jfrog-artifactory-oss-6.9.6.zip -d /opt/artifactory 1>/dev/null
sudo chown -R artifactory: /opt/artifactory/*
sudo rm -rf jfrog-artifactory-oss-6.9.6.zip
echo "            -> Done"

# Starting Artifactory Service
echo "*****Starting Artifactory Service"
sudo systemctl start artifactory 1>/dev/null
sudo systemctl enable artifactory 


# Check if Artifactory is working
sudo systemctl is-active --quiet artifactory
if [ $? -eq 0 ]; then
	echo "Artifactory installed Successfully"
	echo "Access Artifactory using $(curl -s ifconfig.me):8081"
else
	echo "Artifactory installation failed"
fi

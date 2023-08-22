#!/bin/bash

# Update package index and install necessary packages
sudo apt update
sudo apt install -y wget unzip openjdk-11-jdk

# Install Maven 3.9.4
wget https://apache.osuosl.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz
sudo mkdir /opt/maven
sudo tar -xzf apache-maven-3.9.4-bin.tar.gz -C /opt/maven
rm apache-maven-3.9.4-bin.tar.gz

# Configure environment variables for Maven
echo 'export M2_HOME=/opt/maven/apache-maven-3.9.4' >> ~/.bashrc
echo 'export PATH=$PATH:$M2_HOME/bin' >> ~/.bashrc
source ~/.bashrc

# Download and install SonarQube
sudo mkdir /opt/sonarqube
sudo chown -R $USER:$USER /opt/sonarqube

wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip
unzip sonarqube-9.0.1.46107.zip -d /opt/sonarqube
rm sonarqube-9.0.1.46107.zip

# Configure SonarQube
echo "sonar.jdbc.username=sonar" | sudo tee -a /opt/sonarqube/sonarqube-9.0.1.46107/conf/sonar.properties
echo "sonar.jdbc.password=sonar" | sudo tee -a /opt/sonarqube/sonarqube-9.0.1.46107/conf/sonar.properties
echo "sonar.jdbc.url=jdbc:postgresql://localhost/sonar" | sudo tee -a /opt/sonarqube/sonarqube-9.0.1.46107/conf/sonar.properties

# Start SonarQube
/opt/sonarqube/sonarqube-9.0.1.46107/bin/linux-x86-64/sonar.sh start

# Enable SonarQube to start on boot
sudo tee /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube service
After=network.target

[Service]
ExecStart=/opt/sonarqube/sonarqube-9.0.1.46107/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/sonarqube-9.0.1.46107/bin/linux-x86-64/sonar.sh stop
Type=forking
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable sonarqube
sudo systemctl start sonarqube

echo "SonarQube installation completed. You can access it at http://localhost:9000"

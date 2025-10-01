#!/bin/bash
set -e

# Install updates and docker
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube /usr/local/bin/

# Docker Compose stack for Jenkins & SonarQube
cat > /home/ec2-user/stack-compose.yml <<'EOF'
version: '3.8'
services:
  sonar-db:
    image: postgres:13
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar

  sonarqube:
    image: sonarqube:9.9-community
    ports:
      - "9000:9000"
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://sonar-db:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    depends_on:
      - sonar-db

  jenkins:
    image: jenkins/jenkins:lts-jdk11
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home

volumes:
  jenkins_home:
EOF

# Run docker compose
chown ec2-user:ec2-user /home/ec2-user/stack-compose.yml
su - ec2-user -c "cd ~ && docker-compose -f stack-compose.yml up -d"

# Wait for services to stabilize
sleep 90

# Start minikube (docker driver)
su - ec2-user -c "minikube start --driver=docker --kubernetes-version=stable"

# Enable ingress if needed
su - ec2-user -c "minikube addons enable ingress || true"

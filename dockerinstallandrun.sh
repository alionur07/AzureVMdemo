#!/usr/bin/env bash
sudo usermod -aG root swisscom
sudo apt-get update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" -y
sudo apt update -y
sudo apt install docker-ce -y
sudo usermod -aG docker swisscom
sudo chown -R swisscom:swisscom /home/swisscom/. 
#echo f61c30e4-6efd-42a4-a095-c46b551da4b3 | docker login --username 123456798 --password-stdin
docker pull nginx:stable-perl
docker run -d -p 80:80  --name swisscom-nginx  nginx:stable-perl
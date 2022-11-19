#!/bin/bash

set -xe

#install docker

sudo apt-get update && sudo apt-get upgrade -y
yes | sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

#post docker installation
# sudo groupadd docker
sudo usermod -aG docker $USER

sudo apt install docker-compose

#install kubectl, and kubelet 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update 
sudo apt-get install -y kubelet=1.21.14-00 kubectl=1.21.14-00
sudo apt-mark hold kubelet kubectl

#install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
sudo chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

#install helmv3
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#install make
sudo apt install -y make
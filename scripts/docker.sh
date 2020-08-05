#/bin/bash

if which microk8s; then
  echo Found microk8s, will not install docker since it could interfere with k8s networking
  exit 1
fi

snap install docker
apt install -y python3-pip
pip3 install docker-compose

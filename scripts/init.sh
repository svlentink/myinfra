#/bin/bash

if ! grep -iq ubuntu /etc/issue; then
  echo Not Ubuntu
  exit
fi

UBUNTUYEAR=`grep -oh '[0-9]*' /etc/issue|head -1`
if [ "$UBUNTUYEAR" -lt "18" ]; then
  echo Please use Ubuntu 18 or higher
  exit
fi

if [ "$USER" != 'root' ]; then
  echo Please run as root
  exit
fi

# https://community.grafana.com/t/docker-container-run-return-error-exec-format-error/7851/4
[[ `arch` == 'x86_64' ]] || (echo 'Are you on ARM? (lscpu)' && exit)

timedatectl set-timezone CET

apt update
apt upgrade -y
apt install -y \
  apt-transport-https \
  curl \
  git \
  htop \
  python3-pip \
  sudo \
  tmux \
  vim \
  wget

# don't use snap install docker, snap does something with context for docker builds
#docker.io


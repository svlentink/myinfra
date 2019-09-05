#/bin/bash

if grep -iq ubuntu /etc/issue; then
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

which docker 1> /dev/null && echo Already stuff installed && exit

read -n1 -p "Did you copy the essential secrets to its location [Y/n]?" ynq0
[[ "$ynq0" != [Yy] ]] && exit

install_basics() {
  echo $FUNCNAME
  apt update
  apt upgrade -y
  apt install -y \
    apt-transport-https \
    curl \
    git \
    sudo \
    tmux \
    vim
}
install_docker() {
  echo $FUNCNAME
  apt install -y docker.io python3-pip
  pip3 install docker-compose
}
install_microk8s() {
  echo $FUNCNAME
  snap install microk8s --classic
  sleep 120
  microk8s.start
  microk8s.status
  which kubectl || snap alias microk8s.kubectl kubectl
  microk8s.enable dashboard dns ingress
  
  kubectl get all --all-namespaces
  kubectl cluster-info
  kubectl apply --kustomize ./kustomize
}
install_dropbox() {
  echo $FUNCNAME
  git clone https://github.com/svlentink/dockerfiles.git /var/dockerfiles
  cd /var/dockerfiles/docker-compose/dropbox
  docker-compose up -d
  echo You should open the link that will be provide by dropbox inside your browser
  echo wait for it . . .
  sleep 30
  docker-compose logs
  cd
}
install_stack() {
  echo $FUNCNAME
  # TODO
  # stack: https://github.com/svlentink/debian_scripts/blob/master/stack.sh
}
install_mywebsites() {
  echo $FUNCNAME
  # TODO
}
install_webide() {
  echo $FUNCNAME
  # TODO
}
install_mywordpress() {
  echo $FUNCNAME
  # TODO
}


echo After a No, all preceding will also be no.
read -n1 -p "Install basics [Y/n]?" ynq1
read -n1 -p "Install docker [Y/n]?" ynq2
read -n1 -p "Install Dropbox as storage sync [Y/n]?" ynq3
read -n1 -p "Install microk8s [Y/n]?" ynq4
read -n1 -p "Install mywebsites [Y/n]?" ynq5
read -n1 -p "Install and mount Stack [Y/n]?" ynq6
read -n1 -p "Install webide [Y/n]?" ynq7
read -n1 -p "Install mywordpress [Y/n]?" ynq8

# the '|| exit' at the end, results in it stopping after one No
[[ "$ynq1" == [Yy] ]] && install_basics || exit
[[ "$ynq2" == [Yy] ]] && install_docker || exit
[[ "$ynq3" == [Yy] ]] && install_dropbox || exit
[[ "$ynq4" == [Yy] ]] && install_microk8s || exit
[[ "$ynq5" == [Yy] ]] && install_mywebsites || exit
[[ "$ynq6" == [Yy] ]] && install_stack || exit
[[ "$ynq7" == [Yy] ]] && install_webide || exit
[[ "$ynq8" == [Yy] ]] && install_mywp || exit


echo Finished $0

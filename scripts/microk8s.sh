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

which docker 1> /dev/null && echo Already stuff installed && exit


# if you do not have sudo, microk8s fails...
#  su ubuntu
echo 'root ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/root
# https://microk8s.io/docs


snap install microk8s --classic
sleep 120
microk8s.start
microk8s status --wait-ready
which kubectl || snap alias microk8s.kubectl kubectl
# DNS is needed if you want to have internet access from within pods
microk8s.enable ingress storage dns #dashboard

kubectl get all --all-namespaces
kubectl cluster-info


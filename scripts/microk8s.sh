#/bin/sh

if ! grep -iq ubuntu /etc/issue; then
  echo Not Ubuntu
  exit 1
fi

UBUNTUYEAR=`grep -oh '[0-9]*' /etc/issue|head -1`
if [ "$UBUNTUYEAR" -lt "18" ]; then
  echo Please use Ubuntu 18 or higher
  exit 1
fi

if [ "$USER" != 'root' ]; then
  echo Please run as root
  exit 1
fi

if which docker 1> /dev/null; then
  echo "ERROR Already docker installed, not installing k8s"
  exit 1
fi

if which kubectl 1> /dev/null; then
  echo "WARNING kubectl already found on this machine, not installing microk8s"
  exit
fi

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
microk8s.enable ingress storage dns metrics-server #dashboard

kubectl get all --all-namespaces
kubectl cluster-info
kubectl top pod -A --containers

echo Sleeping a while to make sure the cluster is ready
sleep 120


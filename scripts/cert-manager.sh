#!/bin/sh

version=`curl -sSI https://github.com/jetstack/cert-manager/releases/latest|grep 'location:'|grep -o 'v[0-9]\.[0-9]\.[0-9]'`
version='v1.2.0'

echo $version > /var/log/installed-cert-manager-version.txt

curl -Lo /tmp/cert-manager.yml \
  https://github.com/jetstack/cert-manager/releases/download/$version/cert-manager.yaml

sed -i 's/class:/class_does_not_work_with_microk8s:/' /tmp/cert-manager.yml

kubectl apply --validate=false -f /tmp/cert-manager.yml


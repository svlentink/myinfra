#!/bin/sh

version=`curl -sSI https://github.com/jetstack/cert-manager/releases/latest|grep 'location:'|grep -o 'v[0-9]\.[0-9]\.[0-9]'`

echo $version > /var/log/installed-cert-manager-version.txt

kubectl apply --validate=false -f \
  https://github.com/jetstack/cert-manager/releases/download/$version/cert-manager.yaml


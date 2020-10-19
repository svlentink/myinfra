#!/bin/sh

kubectl -n ingress patch configmap nginx-ingress-udp-microk8s-conf --patch "$(cat patch-udp-cm.yml)"
kubectl -n ingress patch daemonset nginx-ingress-microk8s-controller --patch "$(cat patch-ds.yml)"


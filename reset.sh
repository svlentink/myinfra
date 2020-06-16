#!/bin/sh

microk8s.reset
microk8s.enable ingress storage dns
kubectl apply --kustomize ~/.sekretoj
for i in k8sconf/*.yml;do
  kubectl apply -f $i
done


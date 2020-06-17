#!/bin/sh

df -h|grep '/$'
for i in k8sconf/*-pod-*.yml;do
  kubectl delete -f $i
done
for i in k8sconf/*-pvc-*.yml;do
  kubectl delete -f $i
done
for i in k8sconf/*-pv-*.yml;do
  kubectl delete -f $i
done
microk8s.reset
df -h|grep '/$'
microk8s.enable ingress storage dns
kubectl apply --kustomize ~/.sekretoj
for i in k8sconf/*.yml;do
  kubectl apply -f $i
done


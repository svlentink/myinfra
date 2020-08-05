#!/bin/sh

df -h|grep '/$'
for n in `kubectl get namespaces -o name|grep -v 'kube-'`; do
  kubectl delete $n
done
for pvc in `kubectl get pvc -o name`; do kubectl delete $pvc; done
for pv in `kubectl get pv -o name`; do kubectl delete $pv; done
microk8s.reset

df -h|grep '/$'
microk8s.enable ingress storage dns


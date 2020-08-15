#!/bin/bash

if [ -z "$1" ]; then
  echo "USAGE: $0 [create|apply|delete]"
  exit 1
fi

if [ -n "$2" ]; then
  list="$2"
else
  list=`ls`
fi

for i in $list; do
  if [ -d "$i" ]; then
    KPATH="$i/kustomization.y*ml"
    if [ -f $KPATH ]; then
      echo "$KPATH"
      grep -q "^namespace:" $KPATH && kubectl create namespace "$i"
      kubectl "$1" --kustomize "$i"
      if [[ "$1" == "delete" ]]; then
        kubectl delete namespace "$i"
      fi
    fi
  fi
done


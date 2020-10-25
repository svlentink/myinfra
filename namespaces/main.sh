#!/bin/bash

if [ -z "$1" ]; then
  echo "USAGE: $0 [create|apply|delete]"
  exit 1
else
  ACTION="$1"
  shift
fi

if [ -n "$1" ]; then
  list="$@"
else
  list=`ls`
fi

for i in $list; do
  if [ -d "$i" ]; then
    KPATH="$i/kustomization.y*ml"
    if [ -f $KPATH ]; then
      echo "$KPATH"
      grep -q "^namespace:" $KPATH && kubectl create namespace "$i"
      kubectl "$ACTION" --kustomize "$i"
      if [[ "$ACTION" == "delete" ]]; then
        kubectl delete namespace "$i"
      fi
    fi
  fi
done


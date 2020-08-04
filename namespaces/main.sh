#!/bin/sh

if [ -z "$1" ]; then
  echo "USAGE: $0 [create|apply|delete]"
  exit 1
fi

for i in *; do
  if [ -d "$i" ]; then
    KPATH="$i/kustomization.y*ml"
    if [ -f $KPATH ]; then
      echo "$KPATH"
      grep -q "^namespace:" $KPATH && kubectl create namespace "$i"
      kubectl "$1" --kustomize "$i"
    fi
  fi
done


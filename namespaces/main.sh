#!/bin/bash

if [ -z "$2" ]; then
  echo "USAGE: $0 [create|apply|delete]" dir1 dir2 dir3
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
      if grep "^namespace:" $KPATH; then
	if grep "^namespace:" $KPATH|grep -q "$i"; then
          kubectl create namespace "$i"
	else
	  echo ERROR Namespace in kustomize not the same as dir name
	  exit 1
	fi
      fi
      cd "$i"
        kubectl "$ACTION" --kustomize .
	if [ -f patch.sh ]; then
	  ./patch.sh
	fi
      cd - > /dev/null
      if [[ "$ACTION" == "delete" ]]; then
        kubectl delete namespace "$i"
      fi
    fi
  fi
done


#!/bin/bash

if kubectl get pvc -A|grep -i bound; then
  read -n1 -p "Still volumes mounted, this can affect DBs, are you sure?[Y/n]" YN
  if [[ "$YN" == [Yy] ]]; then
    echo " OK continuing"
  else
    echo " Aborting"
    exit 1
  fi
fi

SEARCH_DIR=/mnt/k8s
OTHER_DIRS="$HOME/.ssh"

PATHS=$(for f in `find $SEARCH_DIR -name '*.yml'`;do grep '^[\t\ ]*path: /' $f|grep -o "/.*"|grep -v '^/tmp'; done|sort)

PREVIOUS_PATH="UNSET"
for p in $PATHS;do
  if [[ "$p" == "$PREVIOUS_PATH"* ]]; then
    #echo "$p part of $PREVIOUS_PATH"
    true
  else
    PREVIOUS_PATH="$p"
    ROOT_PATHS="$p $ROOT_PATHS"
  fi
done

ALL_DIRS="$ROOT_PATHS $OTHER_DIRS"
read -n1 -p "Press any key to backup; $ALL_DIRS" NOT_USED

set -v
tar czf "/tmp/backup-`hostname`-`date +%F`.tgz" $ALL_DIRS


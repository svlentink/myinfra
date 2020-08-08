#!/bin/sh
set -v

if [ ! -f /bin/terraform ]; then
  echo 'This should be run inside the hashicorp/terraform:light container'
  echo 'see https://github.com/hashicorp/terraform/blob/d4ac68423c4998279f33404db46809d27a5c2362/scripts/docker-release/Dockerfile-release'
  exit 1
else
  terraform=/bin/terraform
fi

if [ -z "$1" ]; then
  echo "USAGE: $0 [apply|destroy]"
fi

ls *.tf
terraform init
terraform "$1" -refresh=true -input=false -auto-approve


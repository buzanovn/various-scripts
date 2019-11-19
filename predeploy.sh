#!/bin/bash
# The intent of this script is to prepare environment for deploying anything to a server 

if [ -z "$1" ]; then
    if [ -z "${DEPLOY_KEY}" ]; then
        echo "No deploy key found, nothing to add" 1>&2
        exit 2
    else
        SSH_DEPLOY_KEY="${DEPLOY_KEY}"
        echo "Found deploy key"
    fi
else
    SSH_DEPLOY_KEY="${DEPLOY_KEY}"
    echo "Found deploy key"
fi

mkdir -p ~/.ssh && eval $(ssh-agent -s)
if [ -f /.dockerenv ]; then
  printf "Host *\n\tStrictHostKeyChecking no\n\n" > $HOME/.ssh/config
fi

ssh-add <(echo "${SSH_DEPLOY_KEY}")

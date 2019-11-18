#!/bin/bash

[[ -z "$1" ]] && SSH_DEPLOY_KEY=${DEPLOY_KEY} || SSH_DEPLOY_KEY="$1"

which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
mkdir -p ~/.ssh
eval $(ssh-agent -s)
if [[ -f /.dockerenv ]]; then
  echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
fi
ssh-add <(echo "$SSH_DEPLOY_KEY")

#!/bin/sh
set -u

err() {
  printf "Error: $@" >&2
}

if [ -z "$DEPLOY_KEY" ]; then
  err "Deploy key is not set in environment, setting from arguments"
  DEPLOY_KEY="$1"
  if [ -z "$DEPLOY_KEY" ]; then
    err "No deploy key found, either use 'DEPLOY_KEY' env parameter or pass the key as the first argument to the script"
    exit 1
  fi
fi

if [ -f /etc/os-release ]; then
  eval $(cat /etc/os-release)
  if [ -z "$ID" ]; then
    err "Could not detect your OS type, searching for ssh-agent"
    if [ -z "$(which ssh-agent)" ]; then
      err "Unable to install ssh-agent"
      exit 1
    fi
  else
    case $ID in
    alpine)
      INSTALL_PACKAGES="apk update -q && apk add openssh-client -q"
      ;;
    ubuntu)
      INSTALL_PACKAGES="apt-get update -yqq -o=Dpkg::Use-Pty=0 && apt-get install openssh-client -yqq -o=Dpkg::Use-Pty=0"
      ;;
    *)
      err "Unsupported distribution id: '$ID'"
      exit 2
      ;;
    esac
    which ssh-agent || eval "$INSTALL_PACKAGES"
  fi
fi

LOG_FILE=/tmp/ssh-add-err.log

mkdir -p $HOME/.ssh
eval $(ssh-agent -s)
printf "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

echo "${DEPLOY_KEY}" | base64 -d | ssh-add - >/dev/null 2> $LOG_FILE
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  err "The key was not added"
  err "$(cat $LOG_FILE)"
else
  echo "The key was successfully added"
fi
exit $EXIT_CODE



#!/bin/sh
set -u
if [ -f /etc/os-release ]; then
  eval $(cat /etc/os-release)
  [ -z "$ID" ] && exit 1
fi

case $ID in
  alpine)
    INSTALL_PACKAGES="apk update -q && apk add openssh-client -q"
    ;;
  ubuntu)
    INSTALL_PACKAGES="apt-get update -yqq -o=Dpkg::Use-Pty=0 && apt-get install openssh-client -yqq -o=Dpkg::Use-Pty=0"
    ;;
  *)
    echo "Unsupported distribution $ID"
    exit 2
    ;;
esac

which ssh-agent || eval "$INSTALL_PACKAGES"
mkdir -p $HOME/.ssh
eval $(ssh-agent -s)
printf "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

echo "${DEPLOY_KEY}" | base64 -d | ssh-add - >/dev/null 2> /tmp/ssh-add-err.log
EXIT_CODE=$?
[ $EXIT_CODE -ne 0 ] && { echo "The key was not added"; cat /tmp/ssh-add-err.log } || echo "The key was successfully added"
exit $EXIT_CODE



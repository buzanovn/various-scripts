#!/bin/sh
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

DISTRO_ID=$(cat /etc/os-release | grep ID | head -n1 | cut -d= -f2)

case ${DISTRO_ID} in
    ubuntu)
            apt-get update -qq && apt-get install openssh-client -y
            ;;
    alpine)
            apk update && apk add openssh
            ;;
    *)
            echo "Unknow distribution id: $DISTRO_ID" 1>&2
            exit 3
            ;;
esac

mkdir -p ~/.ssh && eval $(ssh-agent -s)
if [ -f /.dockerenv ]; then
  printf "Host *\n\tStrictHostKeyChecking no\n\n" > $HOME/.ssh/config
fi

echo ${SSH_DEPLOY_KEY} > /tmp/deploy.key

cat /tmp/deploy.key

chmod 400 /tmp/deploy.key
ssh-add /tmp/deploy.key
rm /tmp/deploy.key
echo 'Ready to deploy'

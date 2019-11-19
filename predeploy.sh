#!/bin/sh
# The intent of this script is to prepare environment for deploying any thing to a server
# We check the 


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
            apt-get update -y && apt-get install openssh-client -y
            ;;
    alpine)
            apk update && apk add openssh bash
            ;;
    *)
            echo "Unknow distribution id: $DISTRO_ID" 1>&2
            exit 3
            ;;
esac

mkdir -p ~/.ssh && eval $(ssh-agent -s)
if [[ -f /.dockerenv ]]; then
  printf "Host *\n\tStrictHostKeyChecking no\n\n" | tee $HOME/.ssh/config
fi

bash -c "ssh-add <(echo ${SSH_DEPLOY_KEY}) && echo 'Ready to deploy'"

#!/bin/sh

set -o errexit

if [ "$EUID" != '0' ]; then 
  echo "Error: You should run this script as root" >&2
  exit 1
fi

set -o nounset

GET_DOCKER_DOWNLOAD_URL="https://get.docker.com/"
COMPOSE_VERSION="1.27.2"
COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/run.sh"
COMPOSE_DOWNLOAD_LOCATION="/usr/bin/docker-compose"

install_docker() {
    wget -qO - "${GET_DOCKER_DOWNLOAD_URL}" | sh
    usermod -aG docker "${USER}"
    systemctl enable docker
    printf '\nDocker installed successfully\n\n'
    printf 'Waiting for Docker to start...\n\n'
}

install_docker_compose() {
    wget -qO "${COMPOSE_DOWNLOAD_LOCATION}" "${COMPOSE_DOWNLOAD_URL}"
    chmod +x "${COMPOSE_DOWNLOAD_LOCATION}"
    printf '\nDocker Compose installed successfully\n\n'
}

install_docker
sleep 5
install_docker_compose

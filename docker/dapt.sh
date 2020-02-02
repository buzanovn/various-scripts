#!/usr/bin/env bash

function apt_update() {
    apt-get update -qq
}

function apt_install() {
    apt-get install -qq --no-install-recommends $@
}

ARG="$1"
shift

case ${ARG} in
update)
    apt_update
    ;;
install)
    apt_update && apt_install $@
    ;;
install-from-file)
    apt_update && apt_install $(cat $1 | egrep -v "^\s*(#|$)")
    ;;
clean)
    apt-get clean && rm -rf /var/lib/apt/{lists,cache}
    ;;
set-noninteractive)
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
    ;;
esac

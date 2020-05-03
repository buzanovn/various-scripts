#!/bin/sh

function apt_update() {
    echo "Updating"
    apt-get update -yqq
}

function apt_install() {
    apt-get install -yqq --no-install-recommends $@
}

function apt_install_from_file() {
    apt_install $(cat $1 | egrep -v "^\s*(#|$)")
}

function apt_install_from_directory() {
    for f in $(ls $1 | sort -t - -k 1 -g); do 
        apt_install_from_file $f
    done
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
install-from-directory)
    apt_update && { for f in $(ls $1 | sort -t - -k 1 -g); do apt_install $(cat $f | egrep -v "^\s*(#|$)"); done }
    ;;
clean)
    apt-get clean && rm -rf /var/lib/apt/{lists,cache}
    ;;
set-noninteractive)
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
    echo '* libraries/restart-without-asking boolean true' | debconf-set-selections
    echo 'Dpkg::Use-Pty "0";' > /etc/apt/apt.conf.d/00usepty
    ;;
esac

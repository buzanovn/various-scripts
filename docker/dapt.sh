#!/bin/sh

apt_update() {
    echo "Updating"
    apt-get update -yqq
}

apt_install() {
    apt-get install -yqq --no-install-recommends $@
}

apt_install_from_file() {
    apt_install $(cat $1 | egrep -v "^\s*(#|$)")
}

apt_install_from_directory() {
    for f in $(ls $1 | sort -t - -k 1 -g); do 
        apt_install_from_file $f
    done
}

ACTION="$1"
shift

case ${ACTION} in
update)
    apt_update
    ;;
install)
    apt_update && apt_install $@
    ;;
install-from-file)
    apt_update && apt_install_from_file $1
    ;;
install-from-directory)
    apt_update && apt_install_from_directory $1
    ;;
clean)
    apt-get clean && rm -rf /var/lib/apt/{lists,cache}
    ;;
set-noninteractive)
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
    echo '* libraries/restart-without-asking boolean true' | debconf-set-selections
    echo 'Dpkg::Use-Pty "0";' > /etc/apt/apt.conf.d/00usepty
    ;;
*)
    echo "Unknown action '${ACTION}'"
    exit 1
    ;;
esac

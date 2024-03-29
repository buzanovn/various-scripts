#!/bin/sh

. "$(command -v helpers)"

apt_update() {
    echo "Updating"
    apt-get update -yqq
}

apt_install() {
    apt-get install -yqq --no-install-recommends $@
}

apt_clean() {
    apt-get clean && rm -rf /var/lib/apt/{lists,cache}
}

apt_install_from_file() {
    local package_list="$(packages_list $1)"
    if [ -z "$package_list" ]; then
        echo "File $1 is empty, nothing to install"
    else
        apt_install $package_list
    fi
}

apt_install_from_directory() {
    local file_list="$(directory_file_list $1)"
    if [ -z "$file_list" ]; then 
        echo "Directory $1 is empty, nothing to install"
    else
        for f in $file_list; do 
            apt_install_from_file "$1/$f"
        done
    fi
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
    apt_clean
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

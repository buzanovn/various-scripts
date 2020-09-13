#!/bin/sh
set -x

if [ -z "$DEBUG" ]; then
    QUIET=""
else 
    QUIET="-q"
fi

source "$(command -v helpers)"

PIP3=$(command -v pip3)

HELP=$(cat << EOM
Usage:
    dpip <command>

Commands:
    compile %packagename%                     compiles package from sources
    install %packagename%                     installs package
    compile-from-file %filename%              compiles packages stored in file (default requirements format)
    install-from-file %filename%              installs packages stored in file (default requirements format)
    compile-from-directory %directorypath%    compiles packages stored in files in directory 
    install-from-directory %directorypath%    installs packages stored in files in directory
    self-upgrade                              perform upgrade of pip
    help                                      show this message
EOM
)

help () {
    echo "$HELP"
    if [ -z "$PIP3" ]; then
        echo "pip is not found" >&2
        exit 1
    fi
    echo "\npip version: $($PIP3 -V)"
}

pip_compile() {
    CFLAGS="-g0 -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    $PIP3 install $QUIET \
      --compile \
      --no-cache-dir \
      --global-option=build_ext \
      --global-option="-j$(expr $(nproc) - 1)" \
    $@
}

pip_install() {
     $PIP3 install $QUIET --no-cache-dir $@
}

do_from_file() {
    $($1 -r $2)
}

do_from_directory() {
    local file_list="$(ls $1 | sort -t - -k 1 -g)"
    if [ -z "$file_list" ]; then
        echo "Directory $1 is empty, nothing to install"
    else
        for f in $file_list; do do_from_file $1 $2/$f; done
    fi
}

self_upgrade() {
    $PIP3 install $QUIET --upgrade pip
    hash -r pip3
}

ARG="$1"
shift

case ${ARG} in
compile)
    pip_compile $@
    ;;
install)
    pip_install $@
    ;;
compile-from-file)
    do_from_file "pip_compile" $1
    ;;
install-from-file)
    do_from_file "pip_install" $1
    ;;
compile-from-directory)
    do_from_directory "pip_compile" $1
    ;;
install-from-directory)
    do_from_directory "pip_install" $1
    ;;
self-upgrade)
    self_updgrade
    ;;
help|--help)
    help
    ;;
*)
    $PIP3 $ARG $@
    ;;
esac

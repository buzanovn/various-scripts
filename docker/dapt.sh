#!/bin/sh

PIP3=$(command -v pip3)

pip_compile() {
    CFLAGS="-g0 -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    $PIP3 install -q \
      --compile \
      --no-cache-dir \
      --global-option=build_ext \
      --global-option="-j$(expr $(nproc) - 1)" \
    $@
}

pip_install() {
    $PIP3 install -q --no-cache-dir $@
}

do_from_file() {
    if [ ! -e $2 ]; then
        echo "File $2 does not exist"
    elif [ ! -s $2 ]; then
        echo "File $2 is empty, nothing to install"
    else
        $($1 -r $2)
    fi
}

do_from_directory() {
    local file_list="$(ls $2 | sort -t - -k 1 -g)"
    if [ -z "$file_list" ]; then
        echo "Directory $1 is empty, nothing to install"
    else
        for f in $file_list; do do_from_file $1 $2/$f; done
    fi
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
    $PIP3 install -q --upgrade pip && hash -r pip3
    ;;
*)
    $PIP3 $ARG $@
    ;;
esac

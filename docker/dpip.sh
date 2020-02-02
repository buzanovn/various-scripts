#!/usr/bin/env bash

PIP3=$(command -v pip3)

ARG="$1"
shift

case ${ARG} in
compile)
    CFLAGS="-g0 -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    $PIP3 install -q \
      --compile \
      --no-cache-dir \
      --global-option=build_ext \
      --global-option="-j$(expr $(nproc) - 1)" \
    $@
    ;;
self-upgrade)
    $PIP3 install -q --upgrade pip && hash -r pip3
    ;;
install-package)
    $PIP3 install -q --no-cache-dir $@
    ;;
*)
    $PIP3 $ARG $@
    ;;
esac

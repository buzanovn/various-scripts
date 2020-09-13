#!/bin/sh

directory_file_list() {
    find "$1" -maxdepth 1 ! -path "$1" -type f -exec readlink -f {} \; | sort -t - -k 1 -g
}

packages_list() {
    cat "$1" | egrep -v "^\s(#|$)"
}


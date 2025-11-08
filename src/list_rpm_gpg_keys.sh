#!/usr/bin/env bash
set -euo pipefail

function erase_help() {
    echo -e "\n"
    printSeparator
    printSeparator
    echo "To erase any key from the RPM database, do"
    echo "  sudo rpm --erase <keyname>-<keyversion>-<keyrelease>"
    echo
    echo "Example"
    echo "  sudo rpm --erase gpg-pubkey-9fd62a3f-66f9f05a"
    printSeparator
    printSeparator
}

function print_separator() {
    terminal_width=$(tput cols)
    printf "%.0s-" $(seq 1 "${terminal_width}")
    printf "\n"
}

function list_rpm_gpg_keys() {
    local atleastOneKey=0

    for key in $(rpm -q gpg-pubkey); do
        print_separator "-"
        atleastOneKey=1

        rpm --query "${key}" --queryformat "\
List name    : ${key}\n\
Name         : %{name}\n\
Version      : %{version}\n\
Release      : %{release}\n\
Install date : %{installtime:date}\n\
Packager     : %{packager}\n"
    done

    if [ "${atleastOneKey}" -eq 0 ]; then
        :
    else
        print_separator "-"
    fi
}

function main() {
    list_rpm_gpg_keys
    erase_help
}

main

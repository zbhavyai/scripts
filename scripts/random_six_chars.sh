#!/usr/bin/env bash
set -euo pipefail

function generate_random_string() {
    local length="${1}"

    if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -le 0 ]; then
        echo "Error: Length must be a positive integer." >&2
        exit 1
    fi

    random_letters=$(LC_ALL=C tr -dc '[:lower:]' </dev/urandom | head -c "$length" || true)
    printf "%s\n" "${random_letters}"

}

function main() {
    generate_random_string "${1:-6}"
}

main "$@"

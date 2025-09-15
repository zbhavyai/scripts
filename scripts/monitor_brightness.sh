#!/usr/bin/env bash
set -euo pipefail

function monitor_brightness() {
    local input="${1:-}"

    if ! [[ $input =~ ^([0-9]|[1-9][0-9]|100)$ ]]; then
        echo "Brightness should be an integer between 0 and 100."
        echo "Failed to set brightness."
        return 1
    fi

    local value=$((10#$input))

    sudo ddcutil setvcp 10 "$value" 2>/dev/null || {
        echo "Failed to set brightness."
        return 1
    }
}

function main() {
    monitor_brightness "$@"
}

main "$@"

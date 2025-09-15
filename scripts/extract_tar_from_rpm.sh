#!/usr/bin/env bash
set -euo pipefail

function extract_rpm() {
    local rpmFile="$1"

    [[ -f "$rpmFile" ]] || {
        echo "Error: '$rpmFile' not found." >&2
        exit 1
    }

    local dir
    dir=$(dirname -- "$rpmFile")

    local base
    base=$(basename -- "$rpmFile" .rpm)

    local out="${dir}/${base}.tar.gz"

    rpm2archive "$rpmFile" >"$out"
}

function main() {
    extract_rpm "$1"
}

main "$@"

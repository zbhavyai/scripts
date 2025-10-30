#!/usr/bin/env bash
set -euo pipefail

function find_installation_time() {
    date -d "@$(stat / --format='%W')" '+%Y-%m-%d %H:%M:%S %z %Z'
}

function main() {
    find_installation_time
}

main

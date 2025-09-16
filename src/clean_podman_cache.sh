#!/usr/bin/env bash
set -euo pipefail

function clean_podman_cache() {
    podman system prune --force
}

function remove_none_images() {
    podman image list --all | grep '<none>' | awk '{print $3}' | xargs --no-run-if-empty podman image rm --force || true
}

function main() {
    clean_podman_cache
    remove_none_images
}

main

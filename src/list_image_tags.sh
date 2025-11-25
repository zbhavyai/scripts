#!/usr/bin/env bash
set -euo pipefail

function list_image_tags() {
    local image="${1:-}"

    local image_without_tag="${image%%:*}"

    if [[ -z "${image}" ]]; then
        echo "No image specified."
        return 1
    fi

    skopeo list-tags "docker://${image_without_tag}" | jq -r '.Tags[]'
}

function main() {
    list_image_tags "$@"
}

main "$@"

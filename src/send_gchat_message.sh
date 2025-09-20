#!/usr/bin/env bash
set -euo pipefail

function send_gchat_message() {
    local message="${1}"
    local webhook_url="${2}"

    if [[ -z "${message// /}" ]]; then
        echo "Message cannot be empty or blank." >&2
        return 1
    fi

    if [[ -z "${webhook_url}" ]]; then
        echo "Google Chat webhook URL is empty." >&2
        return 1
    elif [[ ! "${webhook_url}" =~ ^https://chat\.googleapis\.com/v1/spaces/[^/]+/messages\?key=[^\&]+\&token=[^\&]+$ ]]; then
        echo "This doesn't look like a Google Chat webhook URL: '${webhook_url}'" >&2
        return 1
    fi

    curl -sSf -X POST "${webhook_url}" -H "Content-Type: application/json" -d "{'text': '${message}'}" || {
        echo "Failed to send message." >&2
        return 1
    }
}

function main() {
    send_gchat_message "${1:-}" "${2:-}"
}

main "$@"

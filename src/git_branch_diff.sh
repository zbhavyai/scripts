#!/usr/bin/env bash
set -euo pipefail

function update_branches() {
    git fetch origin >/dev/null 2>&1 || true
}

function get_branch_diff() {
    local COMPARE_WITH_BRANCH="${1}"
    local BRANCH_TO_COMPARE="HEAD"
    local FILES

    echo "Running branch diff"
    echo "Comparing: ${BRANCH_TO_COMPARE}"
    echo "with     : ${COMPARE_WITH_BRANCH}"
    echo

    update_branches

    FILES=$(git diff --name-only "${BRANCH_TO_COMPARE}...${COMPARE_WITH_BRANCH}")

    if [ -z "${FILES}" ]; then
        echo "No changes detected between branches."
        return
    fi

    echo "Files changed..."
    echo "${FILES}"
    echo

    echo "Generating branch diff..."
    git diff --unified=5 "${BRANCH_TO_COMPARE}...${COMPARE_WITH_BRANCH}"
}

function main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 BRANCH_TO_COMPARE_WITH"
        exit 1
    fi

    get_branch_diff "$@"
}

main "$@"

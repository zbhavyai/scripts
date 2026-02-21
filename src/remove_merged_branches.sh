#!/usr/bin/env bash
set -euo pipefail

CURR_SCRIPT=$(readlink -f "$0")
CURR_SCRIPT_PATH=$(dirname "${CURR_SCRIPT}")

# help
# -------------------------------------------------------------------------------------
function help() {
    echo
    echo "Remove merged branches from this local git repository."
    echo
    echo "Usage:"
    echo "    ${0} [OPTION]"
    echo
    echo "Options:"
    echo "    -r             remove merged branches"
    echo "    -h             show this help message"
    echo
    echo "Examples:"
    echo "    ${0}"
    echo
}

# logging
# -------------------------------------------------------------------------------------
function logger() {
    local LEVEL=$1
    shift
    printf "%s [%5s] %s\n" "$(date +'%F %T.%3N')" "${LEVEL}" "$*"
}
log_info() { logger INFO "$@"; }
log_warn() { logger WARN "$@"; }
log_error() { logger ERROR "$@" 1>&2; }

# update branches
# -------------------------------------------------------------------------------------
function update_branches() {
    git fetch origin >/dev/null 2>&1 || true
}

# remove merged branches except current branch and the release branches
# -------------------------------------------------------------------------------------
function remove_merged_branches() {
    update_branches

    local branches
    branches="$(git branch --merged | grep -vE '^\*|main|master|release' || true)"

    if [[ -z "${branches}" ]]; then
        log_info "No merged branches found on local repository."
        return
    fi

    echo
    log_info "Merged branches:"
    echo "${branches}"
    echo

    log_info "Removing merged branches..."
    printf '%s\n' "${branches}" | xargs -r git branch -d
}

# driver code
# -------------------------------------------------------------------------------------
while getopts ":hr" opt; do
    case "${opt}" in
    h)
        help
        exit
        ;;
    r)
        remove_merged_branches
        exit
        ;;
    \?)
        log_error "Invalid option. Use -h for help."
        exit 1
        ;;
    esac
done

if ((OPTIND == 1)); then
    help
    exit
fi

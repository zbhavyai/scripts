#!/usr/bin/env bash
set -euo pipefail

CURR_SCRIPT=$(readlink -f "$0")
CURR_SCRIPT_PATH=$(dirname "${CURR_SCRIPT}")

# help
# -------------------------------------------------------------------------------------
function help() {
    echo
    echo "Generate diff between current branch and a base branch."
    echo
    echo "Usage:"
    echo "    ${0} [OPTION]"
    echo
    echo "Options:"
    echo "    -b <branch>    generate diff against base branch (default: main)"
    echo "    -h             show this help message"
    echo
    echo "Examples:"
    echo "    ${0}"
    echo "    ${0} -b main"
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

# generate branch diff
# -------------------------------------------------------------------------------------
function generate_branch_diff() {
    local BASE_BRANCH=$1
    local CURRENT_BRANCH

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    log_info "Current branch : ${CURRENT_BRANCH}"
    log_info "Base branch    : ${BASE_BRANCH}"

    if ! git show-ref --verify --quiet "refs/heads/${BASE_BRANCH}" &&
        ! git show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}"; then
        log_error "Base branch '${BASE_BRANCH}' does not exist"
        exit 1
    fi

    update_branches

    local FILES
    FILES=$(git --no-pager diff --name-status "${BASE_BRANCH}...HEAD")

    if [[ -z "${FILES}" ]]; then
        log_info "No changes detected."
        return
    fi

    echo
    log_info "Files changed:"
    echo "${FILES}"
    echo

    log_info "Generating diff..."
    git --no-pager diff --unified=5 "${BASE_BRANCH}...HEAD"
}

# driver code
# -------------------------------------------------------------------------------------
BASE_BRANCH="main"

while getopts ":hb:" opt; do
    case "${opt}" in
    h)
        help
        exit 0
        ;;
    b)
        BASE_BRANCH="${OPTARG}"
        ;;
    \?)
        log_error "Invalid option"
        help
        exit 1
        ;;
    :)
        log_error "Option -${OPTARG} requires an argument"
        exit 1
        ;;
    esac
done

generate_branch_diff "${BASE_BRANCH}"

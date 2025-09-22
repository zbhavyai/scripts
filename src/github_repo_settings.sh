#!/usr/bin/env bash
set -euo pipefail

function settings_general_features() {
    gh api "repos/${1}/${2}" \
        --method PATCH \
        --silent \
        --field has_wiki=false \
        --field has_issues=true \
        --field has_discussions=true \
        --field has_projects=false
}

function settings_general_pull_requests() {
    gh api "repos/${1}/${2}" \
        --method PATCH \
        --silent \
        --field allow_merge_commit=false \
        --field allow_squash_merge=true \
        --field squash_merge_commit_title=PR_TITLE \
        --field squash_merge_commit_message=PR_BODY \
        --field allow_rebase_merge=false \
        --field allow_update_branch=true \
        --field allow_auto_merge=false \
        --field delete_branch_on_merge=true
}

function main() {
    local owner="$1"
    local repo="$2"

    if [[ -z "$owner" || -z "$repo" ]]; then
        echo "Invalid repository format. Use 'owner' 'repo'." >&2
        exit 1
    fi

    settings_general_features "$owner" "$repo"
    settings_general_pull_requests "$owner" "$repo"
}

main "$@"

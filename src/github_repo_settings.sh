#!/usr/bin/env bash
set -euo pipefail

function settings_general_features() {
    printf "%-16s: " "General Features"

    gh api "repos/${1}" \
        --method PATCH \
        --silent \
        --field has_wiki=false \
        --field has_issues=true \
        --field has_discussions=true \
        --field has_projects=false

    printf "%s\n" "$?"
}

function settings_general_pull_requests() {
    printf "%-16s: " "Pull Requests"

    gh api "repos/${1}" \
        --method PATCH \
        --silent \
        --field allow_merge_commit=false \
        --field allow_squash_merge=true \
        --field squash_merge_commit_title=PR_TITLE \
        --field squash_merge_commit_message=COMMIT_MESSAGES \
        --field allow_rebase_merge=false \
        --field allow_update_branch=true \
        --field allow_auto_merge=false \
        --field delete_branch_on_merge=true

    printf "%s\n" "$?"
}

function settings_rules_rulesets_branch() {
    printf "%-16s: " "Branch Rulesets"

    tmp_file=$(mktemp)
    cat >"${tmp_file}" <<'JSON'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["~DEFAULT_BRANCH", "refs/heads/main"]
    }
  },
  "rules": [
    { "type": "creation" },
    { "type": "deletion" },
    { "type": "required_linear_history" },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "automatic_copilot_code_review_enabled": false,
        "allowed_merge_methods": ["squash"]
      }
    },
    { "type": "non_fast_forward" }
  ]
}
JSON

    gh api "repos/${1}/rulesets" \
        --method POST \
        --silent \
        --input "${tmp_file}"

    printf "%s\n" "$?"
}

function settings_rules_rulesets_tag() {
    printf "%-16s: " "Tag Rulesets"

    tmp_file=$(mktemp)
    cat >"${tmp_file}" <<'JSON'
{
  "name": "tag",
  "target": "tag",
  "enforcement": "active",
  "bypass_actors": [
    {
      "actor_id": 5,
      "actor_type": "RepositoryRole",
      "bypass_mode": "always"
    }
  ],
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["refs/tags/v*.*.*"]
    }
  },
  "rules": [
    { "type": "creation" },
    { "type": "update" },
    { "type": "deletion" },
    { "type": "required_linear_history" },
    { "type": "non_fast_forward"}
  ]
}
JSON

    gh api "repos/${1}/rulesets" \
        --method POST \
        --silent \
        --input "${tmp_file}"

    printf "%s\n" "$?"
}

function main() {
    local repo="${1}"

    if [[ -z "${repo}" ]]; then
        echo "Invalid repository format. Use 'owner' 'repo'." >&2
        exit 1
    fi

    settings_general_features "${repo}"
    settings_general_pull_requests "${repo}"
    settings_rules_rulesets_branch "${repo}"
    settings_rules_rulesets_tag "${repo}"
}

main "$@"

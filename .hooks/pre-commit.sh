#!/usr/bin/env bash
set -euo pipefail

function block() {
    echo -e "\n\n"
    echo "$@"
    echo "[ERROR] Commit blocked."
    exit 1
}

function shell_checks() {
    mapfile -d '' -t staged_sh < <(git diff --cached --name-only -z --diff-filter=ACMR -- '*.sh' || true)

    if ((${#staged_sh[@]} == 0)); then
        return 0
    fi

    for f in "${staged_sh[@]}"; do
        if [[ ! -f "$f" ]]; then
            continue
        fi

        shellcheck -e SC2034 -- "$f" || block "[ERROR] ShellCheck failed for $f"
    done
}

(shell_checks) || exit $?

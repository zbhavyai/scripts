#!/usr/bin/env bash
set -euo pipefail

function block() {
    echo -e "\n\n"
    echo "$@"
    echo "[ERROR] Commit blocked."
    exit 1
}

function shell_lint() {
    mapfile -d '' -t staged_sh < <(git diff --cached --name-only -z --diff-filter=ACMR -- '*.sh' || true)

    if ((${#staged_sh[@]} == 0)); then
        return 0
    fi

    for f in "${staged_sh[@]}"; do
        if [[ ! -f "$f" ]]; then
            continue
        fi

        if ! shfmt -d -i 4 -- "$f"; then
            block "[ERROR] shfmt check failed for $f"
        fi

        if ! shellcheck -e SC2034 -- "$f"; then
            block "[ERROR] ShellCheck failed for $f"
        fi
    done
}

(shell_lint) || exit $?

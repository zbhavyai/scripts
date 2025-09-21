#!/usr/bin/env bash
set -euo pipefail

function block() {
    echo -e "\n\n"
    echo "$@"
    echo "[ERROR] Commit blocked."
    exit 1
}

CHECKS="shell_lint py_lint"

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
            block "[ERROR] shfmt failed for $f"
        fi

        if ! shellcheck -e SC2034 -- "$f"; then
            block "[ERROR] shellcheck failed for $f"
        fi
    done
}

function py_lint() {
    mapfile -d '' -t staged_py < <(git diff --cached --name-only -z --diff-filter=ACMR -- '*.py' || true)

    if ((${#staged_py[@]} == 0)); then
        return 0
    fi

    if ! ruff format --check --quiet --force-exclude -- "${staged_py[@]}"; then
        block "[ERROR] ruff format failed"
    fi

    if ! ruff check --quiet --force-exclude -- "${staged_py[@]}"; then
        block "[ERROR] ruff check failed"
    fi

    if ! mypy --pretty -- "${staged_py[@]}"; then
        block "[ERROR] mypy failed"
    fi
}

for CHECK in $CHECKS; do
    ($CHECK) || exit $?
done

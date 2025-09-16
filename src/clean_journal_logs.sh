#!/usr/bin/env bash
set -euo pipefail

function clean_journal_logs() {
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s || true
}

function main() {
    clean_journal_logs
}

main

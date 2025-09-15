#!/usr/bin/env bash
set -euo pipefail

function fix_jetbrains_markdown_preview() {
    # source - https://stackoverflow.com/a/79662857/16018083
    # note that `idea.system.path` is configured according to https://github.com/zbhavyai/fedora-setup
    rm -f "${HOME}"/.config/jetbrains/intellij-idea/system/jcef_cache/Singleton*
    rm -f "${HOME}"/.config/jetbrains/pycharm/system/jcef_cache/Singleton*
    rm -f "${HOME}"/.config/jetbrains/webstorm/system/jcef_cache/Singleton*
}

function main() {
    fix_jetbrains_markdown_preview
}

main

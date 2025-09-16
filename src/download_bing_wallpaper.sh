#!/usr/bin/env bash
set -euo pipefail

function download_bing_wallpaper() {
    local URL_BASE
    local IMAGE_NAME
    URL_BASE=$(curl -sSf "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US" | jq -r '.images[0].urlbase')
    IMAGE_NAME=$(echo "${URL_BASE}" | grep -oP 'OHR\.\K[^_]+')
    curl -sSf -o "${IMAGE_NAME}.webp" -H "Accept: image/webp,image/*;q=0.8" "https://www.bing.com${URL_BASE}_1920x1080.webp"
}

function main() {
    download_bing_wallpaper
}

main

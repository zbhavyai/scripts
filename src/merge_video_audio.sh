#!/usr/bin/env bash
set -euo pipefail

function merge_with_fade() {
    local video="${1}"
    local audio="${2}"
    local fade="${3:-5}"

    if [[ ! -f "${video}" ]]; then
        echo "Error: Video file '${video}' not found." >&2
        exit 1
    fi

    if [[ ! -f "${audio}" ]]; then
        echo "Error: Audio file '${audio}' not found." >&2
        exit 1
    fi

    # video duration in seconds
    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${video}")

    # compute fade-out start time (video_length - fade_duration)
    local end_fade
    end_fade=$(awk -v dur="${duration}" -v fade="${fade}" 'BEGIN { printf "%.2f", dur - fade }')

    # build output filename in same directory as video
    local dir base out
    dir=$(dirname -- "${video}")
    base=$(basename -- "${video}")
    out="${dir}/${base%.*}_merged.mp4"

    echo "Merging '${video}' + '${audio}' with ${fade}s fade in/out → '${out}'"

    ffmpeg -i "${video}" -i "${audio}" \
        -filter_complex "[1:a]afade=t=in:ss=0:d=${fade},afade=t=out:st=${end_fade}:d=${fade}[aud]" \
        -map 0:v -map "[aud]" -c:v copy -c:a aac -shortest "${out}"

    echo "Done: ${out}"
}

function main() {
    merge_with_fade "$@"
}

main "$@"

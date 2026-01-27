#!/usr/bin/env bash
set -euo pipefail

# help function
# -------------------------------------------------------------------------------------
function Help() {
    echo
    echo "Manually download Ollama model blobs + manifest into the correct volume directory."
    echo
    echo "Usage:"
    echo "    ${0} -m <model[:tag]> [-e <engine>] [-v <volume>] [-h]"
    echo
    echo "Options:"
    echo "    -m <model[:tag]>     model and optional tag (e.g. gemma3:27b, qwen3-vl:latest)"
    echo "    -e <engine>          container engine: docker or podman (default: docker)"
    echo "    -v <volume>          container volume name holding Ollama data (default: ollama_data)"
    echo "    -h                   show this help message"
    echo
    echo "Examples:"
    echo "-> Download gemma3:27b using docker and volume 'ollama_data'"
    echo "    ${0} -m gemma3:27b"
    echo
    echo "-> Download qwen3-vl:latest using podman and custom volume"
    echo "    ${0} -m qwen3-vl:latest -e podman -v ollamaStore"
    echo
}

# utility: exit with error message
# -------------------------------------------------------------------------------------
function error() {
    echo "[ERROR] ${1}" >&2
    exit 1
}

# utility: check required commands exist
# -------------------------------------------------------------------------------------
function require_cmd() {
    command -v "${1}" >/dev/null 2>&1 || error "Missing required command: ${1}"
}

# parse model name and tag
# -------------------------------------------------------------------------------------
function parse_model() {
    name="${model_arg%%:*}"
    tag="${model_arg##*:}"
    [[ "${tag}" == "${name}" ]] && tag="latest"

    echo "[ INFO] Model    : ${name}:${tag}"
    echo "[ INFO] Engine   : ${engine}"
    echo "[ INFO] Volume   : ${volume}"
    echo
}

# resolve volume mountpoint to locate Ollama model directory
# -------------------------------------------------------------------------------------
function resolve_volume_path() {
    if ! inspect_json="$(${engine} volume inspect "${volume}" 2>/dev/null)"; then
        error "Volume '${volume}' not found on engine '${engine}'."
    fi

    volume_path="$(echo "${inspect_json}" | jq -r '.[0].Mountpoint')"
    [[ -z "${volume_path}" || "${volume_path}" == "null" ]] && error "Could not resolve volume mountpoint."

    model_dir="${volume_path}/models"
    manifest_dir="${model_dir}/manifests/registry.ollama.ai/library/${name}"

    echo "[ INFO] Resolved Ollama model directory: '${model_dir}'"
    echo
}

# ensure directory structure exists
# -------------------------------------------------------------------------------------
function prepare_directories() {
    mkdir -p "${model_dir}/blobs"
    mkdir -p "${manifest_dir}"
}

# download manifest JSON from registry
# -------------------------------------------------------------------------------------
function fetch_manifest() {
    echo "[ INFO] Fetching manifest for '${name}:${tag}'"

    manifest="$(curl -sL "https://registry.ollama.ai/v2/library/${name}/manifests/${tag}")" || {
        error "Failed to retrieve manifest."
    }

    errors="$(jq -r ".errors?" <<<"${manifest}")"
    [[ "${errors}" != "null" ]] && error "Registry returned errors: ${errors}"

    config="$(jq -r ".config.digest" <<<"${manifest}")"
    [[ -z "${config}" ]] && error "Manifest missing config digest"

    conf_file="${config/:/-}"
    echo
}

# download config blob into blobs directory
# -------------------------------------------------------------------------------------
function download_config_blob() {
    echo "[ INFO] Downloading config blob"

    curl -#L -C - -o "${model_dir}/blobs/${conf_file}" \
        "https://registry.ollama.ai/v2/library/${name}/blobs/${config}" || {
        error "Failed to download config blob."
    }
    echo
}

# download each layer blob
# -------------------------------------------------------------------------------------
function download_layers() {
    echo "[ INFO] Downloading model layers…"

    layers="$(jq -r ".layers[].digest" <<<"${manifest}")"

    for layer in ${layers}; do
        layer_file="${layer/:/-}"
        echo "[ INFO]  → ${layer}"

        curl -#L -C - -o "${model_dir}/blobs/${layer_file}" \
            "https://registry.ollama.ai/v2/library/${name}/blobs/${layer}" || {
            error "Failed to download layer: ${layer}"
        }
    done
}

# write manifest JSON to disk
# -------------------------------------------------------------------------------------
function save_manifest() {
    echo "[ INFO] Saving manifest"
    echo "${manifest}" >"${manifest_dir}/${tag}"
}

# parse CLI inputs via getopts
# -------------------------------------------------------------------------------------
function parse_options() {
    model_arg=""
    engine="docker"
    volume="ollama_data"

    while getopts ":m:e:v:h" opt; do
        case "${opt}" in
        m)
            model_arg="${OPTARG}"
            ;;
        e)
            engine="${OPTARG}"
            ;;
        v)
            volume="${OPTARG}"
            ;;
        h)
            Help
            exit 0
            ;;
        \?)
            error "Invalid option: -${OPTARG}"
            ;;
        :)
            error "Option -${OPTARG} requires an argument"
            ;;
        esac
    done

    if [[ -z "${model_arg}" ]]; then
        Help
        exit 1
    fi
}

# driver function
# -------------------------------------------------------------------------------------
function main() {
    require_cmd jq
    require_cmd curl

    parse_options "$@"
    parse_model
    resolve_volume_path
    prepare_directories
    fetch_manifest
    download_config_blob
    download_layers
    save_manifest

    echo "[ INFO] Download complete!"
    echo "[ INFO] Model '${name}:${tag}' installed successfully."
}

main "$@"

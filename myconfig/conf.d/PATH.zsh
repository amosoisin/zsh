add_path() {
    local ext_path="${1}"

    # ディレクトリ存在確認
    if [[ ! -d "${ext_path}" ]]; then
        echo "Warning: ${ext_path} does not exist, skipping PATH addition" >&2
        return 1
    fi

    export PATH="${PATH}:${ext_path}"
}

add_path "${HOME}/.local/bin/"
add_path "${HOME}/go/bin"

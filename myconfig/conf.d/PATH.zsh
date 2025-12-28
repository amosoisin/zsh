add_path() {
    local ext_path="${1}"

    # ディレクトリ存在確認
    require_directory "${ext_path}" "${ext_path} does not exist, skipping PATH addition" || return 1

    export PATH="${PATH}:${ext_path}"
}

add_path "${HOME}/.local/bin/"
add_path "${HOME}/go/bin"

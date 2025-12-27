add_path() {
    local ext_path="${1}"

    export PATH="${PATH}:${ext_path}"
}

add_path "${HOME}/.local/bin/"
add_path "${HOME}/go/bin"

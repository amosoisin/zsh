load_env() {
    local env_file="${1}"

    [ -f "${env_file}" ] && . "${env_file}"
}

load_env "${HOME}/.cargo/env"
load_env "$HOME/.local/bin/env"

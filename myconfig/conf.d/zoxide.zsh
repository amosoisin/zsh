set_zoxide_config() {
    # zoxideコマンドの存在確認
    if ! command -v zoxide &>/dev/null; then
        echo "Warning: zoxide not installed, falling back to standard cd" >&2
        return 1
    fi

    eval "$(zoxide init zsh)"
    eval "$(zoxide init zsh --cmd cd)"
}

set_zoxide_config

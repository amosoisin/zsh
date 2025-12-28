set_zoxide_config() {
    # zoxideコマンドの存在確認
    require_command zoxide "zoxide not installed, falling back to standard cd" "Warning" || return 1

    eval "$(zoxide init zsh)"
    eval "$(zoxide init zsh --cmd cd)"
}

set_zoxide_config

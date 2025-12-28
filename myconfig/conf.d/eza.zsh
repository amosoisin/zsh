# alias for eza
if require_command eza "eza not installed, using default ls" "Warning"; then
    alias e="eza --icons"
    alias el="eza --icons -l"
    alias l="eza --icons"
    alias ll="eza --icons -l"
else
    # フォールバック: 標準lsを使用
    alias l="ls"
    alias ll="ls -l"
fi


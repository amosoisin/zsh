# alias for eza
if command -v eza &>/dev/null; then
    alias e="eza --icons"
    alias el="eza --icons -l"
    alias l="eza --icons"
    alias ll="eza --icons -l"
else
    echo "Warning: eza not installed, using default ls" >&2
    # フォールバック: 標準lsを使用
    alias l="ls"
    alias ll="ls -l"
fi


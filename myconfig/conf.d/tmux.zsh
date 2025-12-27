tmux_layout() {
    tmux split-window -v
    tmux split-window -h
    tmux resize-pane -D 15
    tmux select-pane -t 0
}

tmux_config() {
    if [ -z "$TMUX" ] && [ -t 1 ]; then
        tmux new -A -s dev
    fi

    alias ppp=tmux_layout
}

tmux_config

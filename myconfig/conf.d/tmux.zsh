vh_layout() {
    tmux split-window -v
    tmux split-window -h
    tmux resize-pane -D 20
    tmux select-pane -t 0
}

v_layout() {
    tmux split-window -v
    tmux resize-pane -D 20
    tmux select-pane -t 0
}

h_layout() {
    tmux split-window -h
    tmux resize-pane -R 100
    tmux select-pane -t 0
}


tmux_config() {
    if [ -z "$TMUX" ] && [ -t 1 ]; then
        tmux new -A -s dev
    fi

    alias tvh=vh_layout
    alias tv=v_layout
    alias th=h_layout
}

tmux_config

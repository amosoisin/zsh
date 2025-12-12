# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
# oSee: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-plugins
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

nvim_config() {
    alias vim="nvim"
    alias vi="nvim"

    export VISUAL=nvim
    export EDITOR=nvim
}

nvim_fzf() {
    nvim $(fzf --tmux center)
}

fzf_config() {
    alias fzf="fzf --tmux center"
    alias fvim=nvim_fzf
}

tmux_config
nvim_config

fzf_config

. ${HOME}/.cargo/env

setopt nonomatch
export PATH="${PATH}:${HOME}/go/bin"

nvim_fzf() {
    nvim $(fzf --tmux center)
}

nvim_config() {
    alias vim="nvim"
    alias vi="nvim"
    alias fvim=nvim_fzf

    export VISUAL=nvim
    export EDITOR=nvim
}

nvim_config

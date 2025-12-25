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

git_dirs() {
    # -H: hidden
    # -I: ignoreファイルを含める
    # -g: globオプション
    # -E: exclude pattern
    # -x: execute
    fd -HI -t d -g '**/.git' "${HOME}/data" | xargs dirname
}

cd_git_dir() {
    local dir

    dir=$(git_dirs | \
            sort -u | \
            fzf --tmux center --preview 'tree -C -L 1 {}' --prompt="Git roots>")
    [ -n "${dir}" ] && cd "${dir}"
}
alias cgd=cd_git_dir

# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | sort -u | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

fzf_tab_config() {
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    # set descriptions format to enable group support
    # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
    zstyle ':completion:*:descriptions' format '[%d]'
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix

    zstyle ':completion:*' menu no
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    # custom fzf flags
    # NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
    zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
    # To make fzf-tab follow FZF_DEFAULT_OPTS.
    # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    # switch group using `<` and `>`
    zstyle ':fzf-tab:*' switch-group '<' '>'
}
fzf_config

set_zoxide_config() {
    eval "$(zoxide init zsh)"
    eval "$(zoxide init zsh --cmd cd)"
}
set_zoxide_config

# set extra path
export PATH=$PATH:~/.local/bin/

tmux_config
nvim_config

fzf_config

. ${HOME}/.cargo/env

setopt nonomatch
export PATH="${PATH}:${HOME}/go/bin"

alias e="eza --icons"
alias el="eza --icons -l"
alias l="eza --icons"
alias ll="eza --icons -l"

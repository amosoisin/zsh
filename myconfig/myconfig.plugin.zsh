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

# cdrコマンドを使用できるようにする
# cdr: ディレクトリの移動履歴を表示する
load_cdr() {
    mkdir -p "${HOME}/.cache/shell"

    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
}

# fzf cdr
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi

    zle clear-screen
}
load_cdr
zle -N fzf-cdr
setopt noflowcontrol
bindkey '^q' fzf-cdr

# set extra path
export PATH=$PATH:~/.local/bin/

tmux_config
nvim_config

fzf_config

. ${HOME}/.cargo/env

setopt nonomatch
export PATH="${PATH}:${HOME}/go/bin"

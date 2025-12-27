# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | sort -u | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}

function enable_fzf_history() {
    zle -N fzf-select-history
    bindkey '^r' fzf-select-history
}

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

fzf_config() {
    alias fzf="fzf --tmux center"
    alias fvim=nvim_fzf

    enable_fzf_history
    alias cgd=cd_git_dir
}

fzf_config

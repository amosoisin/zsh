# ============================================================================
# ヘルパー関数ライブラリ
# ============================================================================
# 共通処理を関数化して再利用性を向上
#
# 提供される関数:
#   - require_command    : 単一コマンドの存在確認
#   - require_commands   : 複数コマンドの存在確認
#   - require_directory  : ディレクトリの存在確認
#   - safe_source        : 安全なファイル読み込み
#   - is_docker          : Docker環境判定
#   - is_wsl             : WSL環境判定
#   - is_ssh             : SSH接続判定
# ============================================================================

# ----------------------------------------------------------------------------
# コマンド存在確認ヘルパー
# ----------------------------------------------------------------------------
# 指定されたコマンドが存在するかチェックします
#
# 引数:
#   $1 - コマンド名
#   $2 - カスタムエラーメッセージ（オプション）
#   $3 - エラーレベル（オプション、デフォルト: Error）
#
# 戻り値:
#   0 - コマンドが存在する
#   1 - コマンドが存在しない
#
# 使用例:
#   require_command fzf || return 1
#   require_command fzf "fzf is required for fuzzy search" || return 1
#   require_command eza "eza not installed, using default ls" "Warning" || return 1
# ----------------------------------------------------------------------------
require_command() {
    local cmd="$1"
    local msg="${2:-$cmd is required but not installed}"
    local level="${3:-Error}"

    if ! command -v "$cmd" &>/dev/null; then
        echo "$level: $msg" >&2
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------------
# 複数コマンドの存在確認
# ----------------------------------------------------------------------------
# 複数のコマンドが全て存在するかチェックします
#
# 引数:
#   $@ - コマンド名のリスト
#
# 戻り値:
#   0 - 全てのコマンドが存在する
#   1 - 1つ以上のコマンドが存在しない
#
# 使用例:
#   require_commands fd fzf tree || return 1
# ----------------------------------------------------------------------------
require_commands() {
    local missing=()

    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing required commands: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------------
# ディレクトリ存在確認
# ----------------------------------------------------------------------------
# 指定されたディレクトリが存在するかチェックします
#
# 引数:
#   $1 - ディレクトリパス
#   $2 - カスタムエラーメッセージ（オプション）
#   $3 - エラーレベル（オプション、デフォルト: Warning）
#
# 戻り値:
#   0 - ディレクトリが存在する
#   1 - ディレクトリが存在しない
#
# 使用例:
#   require_directory ~/.local/bin || return 1
#   require_directory "$HOME/go/bin" "Go bin directory not found" || return 1
# ----------------------------------------------------------------------------
require_directory() {
    local dir="$1"
    local msg="${2:-$dir does not exist}"
    local level="${3:-Warning}"

    if [[ ! -d "$dir" ]]; then
        echo "$level: $msg" >&2
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------------
# 安全なsource
# ----------------------------------------------------------------------------
# ファイルの存在を確認してから読み込みます
#
# 引数:
#   $1 - 読み込むファイルのパス
#
# 戻り値:
#   0 - ファイルが存在し、正常に読み込まれた
#   1 - ファイルが存在しない
#
# 使用例:
#   safe_source ~/.cargo/env
#   safe_source "$HOME/.local/bin/env"
# ----------------------------------------------------------------------------
safe_source() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Warning: $file not found, skipping" >&2
        return 1
    fi

    source "$file"
}

# ----------------------------------------------------------------------------
# 環境判定関数
# ----------------------------------------------------------------------------

# Docker環境かどうか判定
#
# 戻り値:
#   0 - Docker環境
#   1 - Docker環境ではない
#
# 使用例:
#   if is_docker; then
#       echo "Running in Docker"
#   fi
is_docker() {
    [[ -f /.dockerenv ]]
}

# WSL環境かどうか判定
#
# 戻り値:
#   0 - WSL環境
#   1 - WSL環境ではない
#
# 使用例:
#   if is_wsl; then
#       echo "Running in WSL"
#   fi
is_wsl() {
    [[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

# SSH接続かどうか判定
#
# 戻り値:
#   0 - SSH接続
#   1 - SSH接続ではない
#
# 使用例:
#   if is_ssh; then
#       echo "Connected via SSH"
#   fi
is_ssh() {
    [[ -n $SSH_CONNECTION ]]
}

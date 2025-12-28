# Zsh設定管理プロジェクト - TODO

このファイルは、プロジェクトの改善タスクを優先度別に管理します。

**最終更新:** 2025-12-28

---

## 📋 タスク管理の方針

### ステータス表記

- `[ ]` 未着手
- `[~]` 作業中
- `[x]` 完了
- `[-]` 保留/スキップ

### 優先度

- **🔴 高（High）**: すぐに実施すべき、影響が大きい
- **🟡 中（Medium）**: 近い将来実施すべき
- **🟢 低（Low）**: 余裕があれば実施

---

## 🔴 高優先度タスク

### エラーハンドリング強化

#### [x] zoxide.zsh: コマンド存在確認の追加

**目的:** zoxideがインストールされていない環境でもエラーを出さず起動

**実施内容:**
```zsh
set_zoxide_config() {
    # helper関数を使用してコマンド存在確認
    require_command zoxide "zoxide not installed, falling back to standard cd" "Warning" || return 1

    eval "$(zoxide init zsh)"
    eval "$(zoxide init zsh --cmd cd)"
}

set_zoxide_config
```

**期待効果:**
- zoxide未インストール環境でも起動可能
- わかりやすい警告メッセージ
- 標準cdへのフォールバック
- helper関数により一貫したエラーハンドリング

**注意点:**
- cdコマンドの置き換えが行われないため、標準cdの動作になる

**ファイル:** `myconfig/conf.d/zoxide.zsh`

---

#### [x] eza.zsh: コマンド存在確認の追加

**目的:** ezaがインストールされていない環境でもエラーを出さず起動

**実施内容:**
```zsh
# helper関数を使用してコマンド存在確認
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
```

**期待効果:**
- eza未インストール環境でも起動可能
- lsへのフォールバック
- helper関数により一貫したエラーハンドリング

**ファイル:** `myconfig/conf.d/eza.zsh`

---

#### [x] fzf.zsh: 依存コマンドの存在確認

**目的:** fzf, fd, treeがインストールされていない環境での安全な起動

**実施内容:**
1. fzf_select_history関数: `require_command` でfzfの確認
2. cd_git_dir関数: `require_commands` でfd, fzf, treeの確認
3. fzf_config関数: `require_command` でfzfの確認

**例:**
```zsh
cd_git_dir() {
    local dir

    # helper関数で依存コマンドの確認
    require_commands fd fzf tree || return 1

    dir=$(git_dirs | \
            sort -u | \
            fzf --tmux center --preview 'tree -C -L 1 {}' --prompt="Git roots>")
    [ -n "${dir}" ] && cd "${dir}"
}
```

**期待効果:**
- 部分的なインストールでもエラーが明確
- 必要なコマンドが明示される
- helper関数により一貫したエラーハンドリング

**ファイル:** `myconfig/conf.d/fzf.zsh`

---

#### [x] PATH.zsh: ディレクトリ存在確認

**目的:** 存在しないディレクトリをPATHに追加しない

**実施内容:**
```zsh
add_path() {
    local ext_path="${1}"

    # helper関数を使用してディレクトリ存在確認
    require_directory "${ext_path}" "${ext_path} does not exist, skipping PATH addition" || return 1

    export PATH="${PATH}:${ext_path}"
}

add_path "${HOME}/.local/bin/"
add_path "${HOME}/go/bin"
```

**期待効果:**
- PATHに無効なディレクトリが追加されない
- わかりやすい警告メッセージ
- helper関数により一貫したエラーハンドリング

**ファイル:** `myconfig/conf.d/PATH.zsh`

---

### ドキュメント整備

#### [ ] README.md作成

**目的:** プロジェクトの概要と使い方を明確化

**実施内容:**

1. **プロジェクト概要**
   - 何のためのプロジェクトか
   - 主な機能
   - スクリーンショット（オプション）

2. **必須要件**
   - zsh バージョン
   - Oh-My-Zsh
   - 依存コマンド（fzf, zoxide, eza等）

3. **インストール方法**
   - 手動インストール手順
   - 自動インストール（install.sh作成後）

4. **使い方**
   - 主要な機能の説明
   - カスタムエイリアス一覧
   - 便利な関数の使い方

5. **カスタマイズ**
   - 設定ファイルの構造
   - 新しい機能の追加方法

6. **トラブルシューティング**
   - よくある問題と解決方法

7. **ライセンス**

**ファイル:** `README.md`（新規作成）

---

#### [ ] 起動時間のベースライン測定

**目的:** パフォーマンス最適化の効果を測定可能にする

**実施内容:**
```bash
# 1. 起動時間を10回測定して平均を算出
echo "Measuring zsh startup time..."
total=0
for i in {1..10}; do
    time_output=$(time zsh -i -c exit 2>&1)
    # timeコマンドの出力から実時間を抽出
    real_time=$(echo "$time_output" | grep real | awk '{print $2}')
    echo "Run $i: $real_time"
    # 秒数に変換して合計（awkで処理）
done

# 2. プラグイン別の読み込み時間
zsh -i -c "zmodload zsh/zprof; source ~/.zshrc; zprof" > startup_profile.txt

# 3. 結果をdocs/performance.mdに記録（新規作成）
```

**期待効果:**
- 現状の起動時間を把握
- 最適化後の改善効果を定量的に評価

**成果物:**
- `docs/performance.md`: 測定結果の記録
- ベースライン: 現在の起動時間（目標: 0.5秒以内）

---

## 🟡 中優先度タスク

### パフォーマンス最適化

#### [-] zcompileの実装（スキップ: スクリプト量が少なく不要）

**目的:** スクリプトをコンパイルして起動を高速化

**実施内容:**

1. **自動zcompileスクリプト作成**
   ```bash
   # scripts/zcompile.sh（新規作成）
   #!/bin/bash

   echo "Compiling zsh configuration files..."

   # メイン設定ファイル
   zcompile ~/.zshrc
   zcompile ~/.p10k.zsh

   # myconfigプラグイン
   zcompile ~/.oh-my-zsh/custom/plugins/myconfig/myconfig.plugin.zsh

   # conf.d/配下を一括コンパイル
   for file in ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/*.zsh; do
       zcompile "$file"
   done

   echo "Compilation complete!"
   ```

2. **zshrc末尾に自動再コンパイル追加**
   ```zsh
   # 変更検出時に自動再コンパイル
   if [[ ! -f ~/.zshrc.zwc ]] || [[ ~/.zshrc -nt ~/.zshrc.zwc ]]; then
       zcompile ~/.zshrc
   fi
   ```

**期待効果:**
- 起動時間 10-20% 短縮
- 特に大きなファイル（p10k.zsh）で効果大

**注意点:**
- .zwcファイルはgitignoreに追加
- 設定変更後は再コンパイルが必要

---

#### [x] プラグインの見直しと最適化

**目的:** 不要なプラグインを削除、必要なプラグインを最適化

**実施内容:**

1. **現在のプラグイン分析**
   ```
   plugins=(
       git                      # 🟢 必須: git補完とエイリアス
       zsh-autosuggestions      # 🟢 必須: コマンド予測
       git-auto-fetch           # 🔴 要検証: バックグラウンド処理が重い可能性
       zsh-syntax-highlighting  # 🟢 必須: シンタックスハイライト
       cd-gitroot               # 🟡 便利: gitルートへcd（頻度次第）
       zsh-256color             # 🔴 要検証: 本当に必要？
       myconfig                 # 🟢 必須: カスタム設定
       zsh-you-should-use       # 🟡 学習期間後は無効化検討
       forgit                   # 🟢 便利: fzf + git
       fzf-tab                  # 🟢 便利: fzf補完
       zsh-completions          # 🟢 便利: 追加補完
   )
   ```

2. **検証タスク**
   - `git-auto-fetch`: 使用頻度と起動への影響を測定
   - `zsh-256color`: 削除して影響を確認（ターミナルが対応していれば不要）
   - `cd-gitroot`: 使用頻度を確認（低ければ削除、関数化）
   - `zsh-you-should-use`: エイリアスを習得済みなら無効化

3. **プラグイン読み込み順序の最適化**
   ```
   plugins=(
       # 基本プラグイン（高速）
       git
       myconfig

       # 補完系（中速）
       zsh-completions
       fzf-tab

       # 重い処理は後半
       zsh-autosuggestions
       forgit

       # syntax-highlightingは最後（必須）
       zsh-syntax-highlighting
   )
   ```

**期待効果:**
- 不要なプラグイン削減で起動高速化
- プラグイン読み込み順序最適化で互換性向上

**成果物:**
- 最適化されたplugins配列
- プラグイン評価レポート（docs/plugins.md）

---

#### [-] 遅延読み込み（Lazy Loading）の実装（スキップ: 対象となる重い処理がない）

**目的:** 重い処理を必要時のみ実行して起動を高速化

**実施内容:**

1. **候補の特定**
   - nvm（Node.js）
   - rbenv/pyenv（Ruby/Python）
   - その他の大きな環境初期化

2. **遅延読み込み実装（例: nvm）**
   ```zsh
   # myconfig/conf.d/lazy_load.zsh（新規作成）

   # nvmの遅延読み込み
   if [[ -d "$HOME/.nvm" ]]; then
       # ダミー関数を定義
       nvm() {
           # 初回呼び出し時に実際のnvmを読み込む
           unfunction nvm
           export NVM_DIR="$HOME/.nvm"
           [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
           # 引数をそのまま実際のnvmに渡す
           nvm "$@"
       }
   fi
   ```

**期待効果:**
- 起動時間の大幅な短縮（特にnvm, rbenv等がある場合）
- 使用時のみ読み込むため、メモリ使用量も削減

**注意点:**
- 初回実行時のみわずかな遅延が発生
- 補完が効かない場合は追加設定が必要

---

### セットアップ自動化

#### [-] install.shの作成（スキップ: Dockerfileで管理）

**目的:** 新環境への導入を簡単にする

**実施内容:**

```bash
#!/bin/bash
# install.sh

set -e  # エラー時に停止

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "=== Zsh Configuration Setup ==="

# 1. 依存コマンドのチェック
echo "Checking dependencies..."
deps=(zsh git)
for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not installed"
        exit 1
    fi
done

# 2. Oh-My-Zshのインストール確認
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh-My-Zsh not found. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. 必須プラグインのインストール
echo "Installing required plugins..."

plugins=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-completions"
)

for plugin in "${plugins[@]}"; do
    plugin_name="${plugin##*/}"
    plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"

    if [[ ! -d "$plugin_dir" ]]; then
        echo "Installing $plugin_name..."
        git clone "https://github.com/${plugin}" "$plugin_dir"
    else
        echo "$plugin_name already installed"
    fi
done

# 4. Powerlevel10kのインストール
if [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]]; then
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM}/themes/powerlevel10k"
fi

# 5. バックアップ
echo "Backing up existing configurations..."
[[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
[[ -f ~/.p10k.zsh ]] && mv ~/.p10k.zsh ~/.p10k.zsh.backup.$(date +%Y%m%d_%H%M%S)

# 6. シンボリックリンク作成
echo "Creating symlinks..."
ln -sf "${REPO_DIR}/zshrc" ~/.zshrc
ln -sf "${REPO_DIR}/p10k.zsh" ~/.p10k.zsh
ln -sf "${REPO_DIR}/myconfig" "${ZSH_CUSTOM}/plugins/myconfig"

# 7. 完了
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Optionally run: p10k configure (to customize prompt)"
echo ""
```

**期待効果:**
- ワンコマンドで環境構築完了
- エラー時の適切な処理
- バックアップ機能

**ファイル:** `install.sh`（新規作成）

---

#### [-] uninstall.shの作成（スキップ: Dockerfileで管理）

**目的:** クリーンなアンインストール手順の提供

**実施内容:**

```bash
#!/bin/bash
# uninstall.sh

set -e

echo "=== Zsh Configuration Uninstall ==="

# 1. シンボリックリンク削除
echo "Removing symlinks..."
[[ -L ~/.zshrc ]] && rm ~/.zshrc
[[ -L ~/.p10k.zsh ]] && rm ~/.p10k.zsh
[[ -L ~/.oh-my-zsh/custom/plugins/myconfig ]] && rm ~/.oh-my-zsh/custom/plugins/myconfig

# 2. バックアップの復元確認
echo ""
echo "Backup files found:"
ls -1 ~/.zshrc.backup.* 2>/dev/null || echo "No backups found"
echo ""
read -p "Restore latest backup? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    latest_backup=$(ls -1t ~/.zshrc.backup.* 2>/dev/null | head -1)
    if [[ -n "$latest_backup" ]]; then
        cp "$latest_backup" ~/.zshrc
        echo "Restored: $latest_backup"
    fi
fi

echo "Uninstall complete!"
```

**ファイル:** `uninstall.sh`（新規作成）

---

## 🟢 低優先度タスク

### 高度な機能追加

#### [x] ヘルパー関数ライブラリの作成

**目的:** 共通処理を関数化して再利用性を向上

**実施内容:**

```zsh
# myconfig/conf.d/helpers.zsh（新規作成）

# コマンド存在確認ヘルパー
require_command() {
    local cmd="$1"
    local msg="${2:-$cmd is required but not installed}"

    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $msg" >&2
        return 1
    fi
    return 0
}

# 複数コマンドの存在確認
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

# 安全なsource
safe_source() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Warning: $file not found, skipping" >&2
        return 1
    fi

    source "$file"
}

# 環境判定
is_docker() {
    [[ -f /.dockerenv ]]
}

is_wsl() {
    [[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

is_ssh() {
    [[ -n $SSH_CONNECTION ]]
}
```

**期待効果:**
- コードの重複削減
- 一貫したエラーハンドリング
- 保守性の向上

---

#### [-] プロファイル機能の追加（スキップ: 不要）

**目的:** 環境ごとに異なる設定を簡単に切り替え

**実施内容:**

```zsh
# myconfig/conf.d/profiles.zsh（新規作成）

# プロファイル選択（環境変数 ZSH_PROFILE で指定）
ZSH_PROFILE="${ZSH_PROFILE:-default}"

case "$ZSH_PROFILE" in
    minimal)
        # 最小限の設定（高速起動）
        export LOAD_FZF=0
        export LOAD_ZOXIDE=0
        ;;
    development)
        # 開発環境用（全機能有効）
        export LOAD_FZF=1
        export LOAD_ZOXIDE=1
        export LOAD_GIT_EXTRAS=1
        ;;
    server)
        # サーバー環境用（リモート接続最適化）
        export LOAD_FZF=0
        export LOAD_ZOXIDE=1
        export MINIMAL_PROMPT=1
        ;;
    *)
        # デフォルト
        export LOAD_FZF=1
        export LOAD_ZOXIDE=1
        ;;
esac
```

**使い方:**
```bash
# 起動時にプロファイル指定
ZSH_PROFILE=minimal zsh

# .zshenvで永続的に設定
echo 'export ZSH_PROFILE=development' >> ~/.zshenv
```

---

#### [-] git hookの追加（スキップ: 不要）

**目的:** コミット前の自動チェック

**実施内容:**

```bash
# .git/hooks/pre-commit（新規作成）

#!/bin/bash

echo "Running pre-commit checks..."

# 1. zsh構文チェック
for file in zshrc myconfig/**/*.zsh; do
    if [[ -f "$file" ]]; then
        echo "Checking $file..."
        zsh -n "$file" || {
            echo "Error: Syntax error in $file"
            exit 1
        }
    fi
done

# 2. TODOの更新チェック
if ! git diff --cached --name-only | grep -q "TODO.md"; then
    echo "Warning: Consider updating TODO.md"
fi

echo "Pre-commit checks passed!"
```

---

### テストとCI/CD

#### [-] テスト環境の構築（スキップ: 不要）

**目的:** 設定の動作確認を自動化

**実施内容:**

```bash
# tests/test_setup.sh（新規作成）

#!/bin/bash

echo "=== Testing Zsh Configuration ==="

# 1. 構文チェック
echo "1. Syntax check..."
zsh -n zshrc || exit 1
for file in myconfig/conf.d/*.zsh; do
    zsh -n "$file" || exit 1
done

# 2. 起動テスト
echo "2. Startup test..."
zsh -i -c "echo 'Startup OK'" || exit 1

# 3. エイリアスチェック
echo "3. Alias check..."
zsh -i -c "alias | grep -q eza && echo 'eza aliases OK'" || echo "Warning: eza aliases not found"

# 4. 関数チェック
echo "4. Function check..."
zsh -i -c "type cd_git_dir &>/dev/null && echo 'cd_git_dir OK'" || echo "Warning: cd_git_dir not found"

echo ""
echo "All tests passed!"
```

---

#### [-] GitHub Actionsの設定（スキップ: 不要）

**目的:** プッシュ時の自動テスト

**実施内容:**

```yaml
# .github/workflows/test.yml（新規作成）

name: Test Zsh Configuration

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install zsh
      run: sudo apt-get install -y zsh

    - name: Syntax check
      run: |
        zsh -n zshrc
        for file in myconfig/conf.d/*.zsh; do
          zsh -n "$file"
        done

    - name: Run tests
      run: bash tests/test_setup.sh
```

---

## 📝 将来的な検討事項

### アイデア（未定）

- [ ] dotfiles統合（vim, tmux, git等との統合管理）
- [ ] プラグインマネージャーの検討（Oh-My-Zsh以外の選択肢）
- [ ] カラースキームのカスタマイズ
- [ ] tmux統合の強化
- [ ] Docker環境専用の最適化
- [ ] パフォーマンスモニタリングダッシュボード
- [ ] 自動アップデート機能

---

## ✅ 完了タスク

### 2025-12-28

- [x] プロジェクト構造の確認
- [x] CLAUDE.md作成
- [x] TODO.md作成（このファイル）
- [x] プラグインの見直しと最適化（zsh-256color削除、読み込み順序最適化）
- [x] ヘルパー関数ライブラリの作成（myconfig/conf.d/helpers.zsh）
- [x] helper関数の拡張（エラーレベル指定、require_directory追加）
- [x] zoxide.zshにhelper関数を適用
- [x] eza.zshにhelper関数を適用
- [x] fzf.zshにhelper関数を適用
- [x] PATH.zshにhelper関数を適用
- [x] myconfig.plugin.zshの読み込み順序修正（helpers.zshを最初に読み込み）

### 2025-12-27

- [x] 設定のモジュール化（myconfig/conf.d/に分割）

### 2025-12-26

- [x] eza移行（exaからの置き換え）
- [x] zsh-completions追加

### 2025-12-25

- [x] zoxide導入（cd/cdr置き換え）

---

## 📊 進捗トラッキング

### 優先度別の進捗

- **高優先度:** 5/7 (71%) - 4完了（エラーハンドリング）、1完了（ヘルパー）、2未着手（ドキュメント）
- **中優先度:** 5/5 (100%) - 1完了、4スキップ
- **低優先度:** 6/6 (100%) - 1完了、5スキップ

**全体:** 16/18 (89%) - 7完了、9スキップ、2未着手

---

## 🎯 次のステップ

1. **ドキュメント整備**（高優先度）
   - README.md作成
   - 起動時間ベースライン測定

2. **実環境でのテスト**
   - `source ~/.zshrc` または `docker restart main` でテスト
   - エラーが出ないことを確認

---

**メンテナー:** s-nishio

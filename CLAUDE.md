# Zsh設定管理プロジェクト - Claude Code指示

このプロジェクトはzshのカスタム設定を管理し、Docker開発環境（およびホスト環境）で使用します。

## プロジェクト概要

**目的:** モジュール化されたzsh設定の管理と、開発環境への適用
**管理方針:** Oh-My-Zshのカスタムプラグイン機能を活用した機能別ファイル分割
**配置先:** ホームディレクトリ（`~/.zshrc`へシンボリックリンク）
**用途:** 個人利用

## ファイル構造

```
.
├── zshrc                    # メインのzsh設定ファイル（.zshrcとしてリンク）
├── p10k.zsh                 # Powerlevel10k設定（自動生成、96KB）
├── myconfig/                # カスタムプラグイン（Oh-My-Zsh形式）
│   ├── myconfig.plugin.zsh  # プラグインエントリーポイント
│   └── conf.d/              # 機能別設定ファイル
│       ├── PATH.zsh         # PATH管理
│       ├── eza.zsh          # ezaエイリアス
│       ├── zoxide.zsh       # zoxide（スマートcd）設定
│       ├── misc.zsh         # その他のzsh設定
│       ├── neovim.zsh       # Neovim統合
│       ├── fzf.zsh          # fzf統合と便利関数
│       └── external.zsh     # 外部環境ファイル読み込み
├── CLAUDE.md                # このファイル
├── TODO.md                  # 実施タスク一覧
└── README.md                # プロジェクト説明（予定）
```

## 設定の理念と方針

### 1. モジュール化原則

**機能ごとにファイルを分割:**
- 1ファイル = 1機能/ツール
- 独立性を保ち、個別に有効/無効化可能
- 関連する設定は同じファイルにまとめる

**命名規則:**
- ツール名.zsh（例: `eza.zsh`, `fzf.zsh`）
- 機能名.zsh（例: `PATH.zsh`, `misc.zsh`）
- 小文字推奨、必要に応じて大文字（PATH等）

### 2. パフォーマンス優先

**起動速度を重視:**
- 遅延読み込み（lazy loading）の活用
- 不要なプラグインは削除
- 重い処理は条件付き実行

**測定方法:**
```bash
# zsh起動時間の計測
time zsh -i -c exit

# プラグイン読み込み時間の詳細
zmodload zsh/zprof
# .zshrc再読み込み
zprof
```

### 3. 堅牢性の確保

**エラーハンドリング:**
- コマンド存在確認（`command -v`）
- ファイル存在確認（`[ -f file ]`）
- フォールバック処理の実装

**安全な初期化:**
- 依存関係のチェック
- エラー時も起動を継続
- 警告メッセージの表示

## 改善時のルール

### 1. 段階的変更

**小さく、確実に:**
- 1度に1つの機能を変更
- 変更後は必ずテスト
- 問題があれば即座にロールバック

**gitコミット:**
```bash
# 機能追加
git add myconfig/conf.d/new_feature.zsh
git commit -m "Add - Add new feature integration"

# 既存機能の改善
git commit -m "Change - Improve fzf history performance"

# バグ修正
git commit -m "Fix - Handle missing command in eza.zsh"
```

### 2. ドキュメント更新

**変更時に必ず更新:**
- CLAUDE.md（方針や重要な変更）
- TODO.md（新たなタスク、完了したタスク）
- README.md（使い方、インストール手順）

### 3. 後方互換性

**既存の動作を壊さない:**
- エイリアスの変更は慎重に
- 環境変数の変更は影響を確認
- 削除より無効化を優先

## パフォーマンス最適化のベストプラクティス

### 1. 遅延読み込み（Lazy Loading）

**重いツールは必要時のみ読み込む:**

```zsh
# 悪い例: 起動時に毎回実行
eval "$(nvm init)"

# 良い例: nvm使用時のみ初期化
nvm() {
    unfunction nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm "$@"
}
```

### 2. zcompileの活用

**スクリプトのコンパイル:**
```bash
# 設定ファイルをコンパイル（高速化）
zcompile ~/.zshrc
zcompile ~/.oh-my-zsh/custom/plugins/myconfig/myconfig.plugin.zsh

# conf.d/配下を一括コンパイル
for file in ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/*.zsh; do
    zcompile "$file"
done
```

**自動コンパイルの実装例:**
```zsh
# zshrc末尾に追加
if [[ ! -f ~/.zshrc.zwc ]] || [[ ~/.zshrc -nt ~/.zshrc.zwc ]]; then
    zcompile ~/.zshrc
fi
```

### 3. プラグイン選定の見直し

**現在のプラグイン（zshrc:81-93）:**
```
plugins=(
    git                      # git補完とエイリアス
    zsh-autosuggestions      # コマンド予測
    git-auto-fetch           # 自動fetch（重い可能性）
    zsh-syntax-highlighting  # シンタックスハイライト
    cd-gitroot               # gitルートへcd
    zsh-256color             # 256色対応
    myconfig                 # カスタム設定
    zsh-you-should-use       # エイリアス推奨
    forgit                   # fzf + git
    fzf-tab                  # fzf補完
    zsh-completions          # 追加補完
)
```

**最適化の検討:**
- `git-auto-fetch`: バックグラウンド処理が重い場合は削除
- `zsh-you-should-use`: 学習済みなら無効化
- プラグインの読み込み順序（syntax-highlightingは最後）

### 4. 条件付き実行

**環境に応じた処理:**
```zsh
# Docker環境でのみ実行
if [[ -f /.dockerenv ]]; then
    # Docker固有の設定
fi

# インタラクティブシェルのみ
if [[ -o interactive ]]; then
    # プロンプト設定など
fi

# SSH接続時のみ
if [[ -n $SSH_CONNECTION ]]; then
    # リモート環境用設定
fi
```

## エラーハンドリングのガイドライン

### 1. コマンド存在確認

**テンプレート:**
```zsh
# パターン1: command -v使用（推奨）
if command -v eza &>/dev/null; then
    alias ls="eza --icons"
else
    echo "Warning: eza not found, using default ls" >&2
fi

# パターン2: type使用
if type eza &>/dev/null; then
    alias ls="eza --icons"
fi

# パターン3: which使用（非推奨、遅い）
# if which eza &>/dev/null; then ...
```

### 2. ファイル/ディレクトリ存在確認

**テンプレート:**
```zsh
# ファイル確認
load_env() {
    local env_file="${1}"

    if [[ ! -f "${env_file}" ]]; then
        echo "Warning: ${env_file} not found" >&2
        return 1
    fi

    source "${env_file}"
}

# ディレクトリ確認
if [[ ! -d "${ZSH_CUSTOM}/plugins/myconfig" ]]; then
    echo "Error: myconfig plugin not found" >&2
    return 1
fi
```

### 3. 安全な関数定義

**テンプレート:**
```zsh
# 依存コマンドのチェック付き関数
cd_git_dir() {
    # 依存コマンドの確認
    local deps=(fd fzf tree)
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: $cmd is required but not installed" >&2
            return 1
        fi
    done

    # 実際の処理
    local dir
    dir=$(git_dirs | sort -u | fzf --tmux center --preview 'tree -C -L 1 {}' --prompt="Git roots>")

    [[ -n "${dir}" ]] && cd "${dir}"
}
```

### 4. 現在のエラーハンドリング状況

**改善が必要なファイル:**

1. **zoxide.zsh** - zoxideコマンドの存在確認なし
2. **eza.zsh** - ezaコマンドの存在確認なし
3. **fzf.zsh** - fd, fzf, treeの存在確認なし
4. **external.zsh** - load_env関数は実装済み（良い）
5. **PATH.zsh** - ディレクトリ存在確認なし

**改善例（zoxide.zsh）:**
```zsh
set_zoxide_config() {
    if ! command -v zoxide &>/dev/null; then
        echo "Warning: zoxide not installed, falling back to standard cd" >&2
        return 1
    fi

    eval "$(zoxide init zsh)"
    eval "$(zoxide init zsh --cmd cd)"
}

set_zoxide_config
```

## 禁止事項

❌ **絶対にやってはいけないこと:**

1. **p10k.zshの手動編集** - `p10k configure`で再生成されるため
2. **グローバルシェル設定の汚染** - 副作用のある変更は関数内で完結
3. **セキュリティリスク** - 信頼できないソースからのeval実行
4. **ハードコーディング** - 絶対パス、環境依存の値
5. **巨大な単一ファイル** - 機能追加時は必ず分割

## 推奨事項

✅ **推奨される作業パターン:**

### 新機能追加時

```bash
# 1. 新しい設定ファイルを作成
vim myconfig/conf.d/new_tool.zsh

# 2. エラーハンドリングを実装
# （コマンド存在確認、フォールバック処理）

# 3. zshrcのpluginsに追加（必要に応じて）

# 4. テスト
source ~/.zshrc
# または
exec zsh

# 5. コミット
git add myconfig/conf.d/new_tool.zsh
git commit -m "Add - Add new_tool integration"

# 6. ドキュメント更新
# CLAUDE.md, TODO.mdを更新
```

### 既存機能の改善時

```bash
# 1. バックアップ
cp myconfig/conf.d/target.zsh myconfig/conf.d/target.zsh.bak

# 2. 変更

# 3. テスト
source ~/.zshrc

# 4. 問題があればロールバック
mv myconfig/conf.d/target.zsh.bak myconfig/conf.d/target.zsh

# 5. 成功したらコミット
git add myconfig/conf.d/target.zsh
git commit -m "Change - Improve target performance"
```

### パフォーマンス測定

```bash
# 起動時間の測定（10回平均）
for i in {1..10}; do time zsh -i -c exit; done

# プラグイン別の読み込み時間
zmodload zsh/zprof
source ~/.zshrc
zprof | head -20

# 特定のコマンド実行時間
time eval "$(zoxide init zsh)"
```

## セットアップとデプロイ

### 手動セットアップ（現状）

```bash
# 1. Oh-My-Zsh必須プラグインのインストール
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-completions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# 2. myconfigプラグインの配置
ln -s /path/to/this/repo/myconfig \
    ~/.oh-my-zsh/custom/plugins/myconfig

# 3. zshrcとp10k.zshのシンボリックリンク作成
ln -sf /path/to/this/repo/zshrc ~/.zshrc
ln -sf /path/to/this/repo/p10k.zsh ~/.p10k.zsh

# 4. 設定の反映
source ~/.zshrc
```

### 自動セットアップ（TODO）

**install.sh作成予定:**
- 依存コマンドのチェック（zsh, git, curl/wget）
- Oh-My-Zshのインストール確認
- 必須プラグインの自動インストール
- シンボリックリンクの作成
- バックアップ機能
- アンインストールスクリプト

## トラブルシューティング

### 起動が遅い

```bash
# 1. 起動時間を測定
time zsh -i -c exit

# 2. プラグイン別の読み込み時間を確認
zmodload zsh/zprof
source ~/.zshrc
zprof

# 3. 重いプラグインを特定して無効化
# zshrcのplugins配列からコメントアウト

# 4. zcompileを実行
zcompile ~/.zshrc
for f in ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/*.zsh; do
    zcompile "$f"
done
```

### コマンドが見つからない

```bash
# 1. PATHを確認
echo $PATH

# 2. PATH.zshの内容を確認
cat ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/PATH.zsh

# 3. 手動でPATHを追加してテスト
export PATH="$PATH:/missing/path"

# 4. 問題なければPATH.zshに追記
```

### エイリアスが効かない

```bash
# 1. エイリアスの定義を確認
alias | grep target_alias

# 2. どのファイルで定義されているか検索
grep -r "alias target_alias" ~/.oh-my-zsh/custom/plugins/myconfig/

# 3. 読み込み順序を確認（プラグインの順序、ファイル名のアルファベット順）

# 4. 明示的に読み込んでテスト
source ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/target.zsh
```

### fzfやzoxideが動かない

```bash
# 1. コマンドがインストールされているか確認
command -v fzf
command -v zoxide

# 2. 初期化が実行されているか確認
type fzf  # 関数として定義されているか
type cd   # zoxideに置き換わっているか

# 3. エラーメッセージを確認
source ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/zoxide.zsh
source ~/.oh-my-zsh/custom/plugins/myconfig/conf.d/fzf.zsh

# 4. 必要に応じて手動インストール
# fzf:    https://github.com/junegunn/fzf
# zoxide: https://github.com/ajeetdsouza/zoxide
```

### myconfigプラグインが読み込まれない

```bash
# 1. プラグインディレクトリの確認
ls -la ~/.oh-my-zsh/custom/plugins/myconfig/

# 2. シンボリックリンクの確認
ls -la ~/.oh-my-zsh/custom/plugins/myconfig
# -> /path/to/repo/myconfig になっているか

# 3. zshrcのplugins配列を確認
grep "plugins=" ~/.zshrc
# myconfigが含まれているか

# 4. myconfig.plugin.zshの構文エラーチェック
zsh -n ~/.oh-my-zsh/custom/plugins/myconfig/myconfig.plugin.zsh
```

## よくある質問（FAQ）

### Q1: なぜ.zshrcではなくzshrcなのか？

**A:** このリポジトリ内ではドットなしで管理し、シンボリックリンク作成時に`~/.zshrc`として配置します。これにより：
- リポジトリ内での視認性向上
- ドットファイルの隠れる問題を回避
- 明示的なデプロイメント

### Q2: p10k.zshを変更したい

**A:** `p10k configure`コマンドを実行して対話的に設定してください。手動編集は推奨されません。変更後、自動的に`~/.p10k.zsh`が更新されるので、それをこのリポジトリにコピーします。

```bash
# 1. 設定変更
p10k configure

# 2. リポジトリに反映
cp ~/.p10k.zsh /path/to/repo/p10k.zsh

# 3. コミット
git add p10k.zsh
git commit -m "Change - Update p10k configuration"
```

### Q3: 新しいプラグインを追加したい

**A:** Oh-My-Zshの公式プラグインか、サードパーティプラグインかで手順が異なります。

**公式プラグイン:**
```bash
# zshrcのpluginsに追加するだけ
plugins=(
    ...
    new-plugin
)
```

**サードパーティプラグイン:**
```bash
# 1. インストール
git clone https://github.com/author/plugin-name \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/plugin-name

# 2. zshrcに追加
plugins=(
    ...
    plugin-name
)

# 3. ドキュメント更新（CLAUDE.md, TODO.md）
```

### Q4: Docker環境とホスト環境で設定を分けたい

**A:** 環境判定を使用します。

```zsh
# myconfig/conf.d/environment.zsh
if [[ -f /.dockerenv ]]; then
    # Docker環境専用設定
    export DOCKER_ENV=1
    alias ll="eza -la --git"
else
    # ホスト環境専用設定
    export HOST_ENV=1
    alias ll="ls -lah"
fi
```

### Q5: パフォーマンスが気になる、何から始めるべき？

**A:** 以下の順序で実施：

1. **測定** - `time zsh -i -c exit`で現状把握
2. **zprof** - `zmodload zsh/zprof && source ~/.zshrc && zprof`で原因特定
3. **低コスト改善** - zcompile実行
4. **プラグイン削減** - 使っていないプラグインを無効化
5. **遅延読み込み** - 重いツールの初期化を遅延

目標: 0.5秒以内（体感で遅延を感じない）

### Q6: エラーハンドリングを追加すると冗長になる

**A:** ヘルパー関数を作成して再利用します。

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

# 使用例
if require_command fzf "fzf is required for fuzzy search features"; then
    # fzfの設定
fi
```

## 参考情報

### 公式ドキュメント

- [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza)

### ベストプラクティス

- [Zsh Performance Tips](https://htr3n.github.io/2018/07/faster-zsh/)
- [Zsh Plugin Standard](https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)

### 改善履歴

- **2025-12-27**: 設定のモジュール化（myconfig/conf.d/に分割）
- **2025-12-26**: eza移行（exaからの置き換え）
- **2025-12-26**: zsh-completions追加
- **2025-12-25**: zoxide導入（cd/cdr置き換え）

---

**最終更新:** 2025-12-28
**対象バージョン:** zsh 5.x, Oh-My-Zsh latest
**メンテナー:** s-nishio

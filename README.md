# Zsh設定管理プロジェクト

モジュール化されたzsh設定を管理し、Docker開発環境およびホスト環境で使用するためのプロジェクトです。

## 概要

このプロジェクトは、Oh-My-Zshのカスタムプラグイン機能を活用して、zshの設定を機能別に分割管理します。各ツールの設定を独立したファイルとして管理することで、保守性と拡張性を向上させています。

### 主な特徴

- **モジュール化された設計** - 機能ごとにファイル分割し、個別に有効/無効化可能
- **堅牢なエラーハンドリング** - コマンドやディレクトリの存在確認を実装
- **モダンなツール統合** - fzf、zoxide、eza、neovimなどを効果的に活用
- **段階的な改善** - gitで履歴管理し、計画的に進化

### 統合されているツール

- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** - 高速で美しいプロンプトテーマ
- **[fzf](https://github.com/junegunn/fzf)** - コマンドライン用のファジーファインダー
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - スマートなcdコマンド代替
- **[eza](https://github.com/eza-community/eza)** - モダンなlsコマンド代替
- **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** - コマンド予測
- **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** - シンタックスハイライト
- **[forgit](https://github.com/wfxr/forgit)** - fzfとgitの統合

## 必須要件

### 基本環境

- **zsh** 5.0以降
- **git** 2.0以降
- **Oh-My-Zsh** ([インストール方法](https://ohmyz.sh/#install))

### 推奨ツール

以下のツールがインストールされていない場合、該当機能は自動的に無効化されます：

```bash
# Debian/Ubuntu
sudo apt install fzf fd-find tree

# macOS (Homebrew)
brew install fzf fd tree zoxide eza

# Rust (cargo)
cargo install zoxide eza
```

## インストール

### 1. リポジトリのクローン

```bash
cd ~/
git clone https://github.com/YOUR_USERNAME/zsh-config.git
# または、既存の場所にある場合はそのパスを使用
```

### 2. Oh-My-Zshのインストール（未インストールの場合）

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. 必須プラグインのインストール

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 4. 既存の設定をバックアップ

```bash
# 既存の.zshrcをバックアップ
[[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
[[ -f ~/.p10k.zsh ]] && mv ~/.p10k.zsh ~/.p10k.zsh.backup.$(date +%Y%m%d_%H%M%S)
```

### 5. シンボリックリンクの作成

```bash
# このリポジトリのパスを設定
REPO_PATH="$HOME/data/docker/mydev-container/config/zsh"  # 実際のパスに変更

# シンボリックリンクを作成
ln -sf "${REPO_PATH}/zshrc" ~/.zshrc
ln -sf "${REPO_PATH}/p10k.zsh" ~/.p10k.zsh
ln -sf "${REPO_PATH}/myconfig" ~/.oh-my-zsh/custom/plugins/myconfig
```

### 6. 設定の反映

```bash
# zshを再起動
exec zsh

# または、設定を再読み込み
source ~/.zshrc
```

## ファイル構造

```
.
├── zshrc                    # メインのzsh設定ファイル
├── p10k.zsh                 # Powerlevel10k設定（96KB）
├── myconfig/                # カスタムプラグイン
│   ├── myconfig.plugin.zsh  # プラグインエントリーポイント
│   └── conf.d/              # 機能別設定ファイル
│       ├── PATH.zsh         # PATH管理
│       ├── eza.zsh          # ezaエイリアス
│       ├── zoxide.zsh       # zoxide設定
│       ├── misc.zsh         # その他のzsh設定
│       ├── neovim.zsh       # Neovim統合
│       ├── fzf.zsh          # fzf統合と便利関数
│       └── external.zsh     # 外部環境ファイル読み込み
├── CLAUDE.md                # Claude Code用ガイド
├── TODO.md                  # タスク管理
└── README.md                # このファイル
```

## 使い方

### エイリアス一覧

#### eza（lsの代替）

```bash
e         # eza --icons
el        # eza --icons -l
l         # eza --icons
ll        # eza --icons -l
```

#### neovim

```bash
vim       # nvim
vi        # nvim
fvim      # fzfでファイルを選択してnvimで開く
```

#### fzf

```bash
Ctrl+R    # fzfでコマンド履歴を検索
cgd       # gitリポジトリをfzfで選択してcd
```

### 便利な関数

#### `cd_git_dir`

ホームディレクトリ配下のgitリポジトリをfzfで選択して移動します。

```bash
cgd
# または
cd_git_dir
```

**依存コマンド:** fd, fzf, tree

#### `nvim_fzf`

fzfでファイルを選択してneovimで開きます。

```bash
fvim
# または
nvim_fzf
```

**依存コマンド:** fzf, nvim

### zoxideの使い方

zoxideは学習型のcdコマンド代替ツールです。頻繁にアクセスするディレクトリに素早く移動できます。

```bash
# 通常のcd（zoxideが記録）
cd ~/data/docker/mydev-container

# 部分一致で移動（学習後）
cd mydev      # ~/data/docker/mydev-containerに移動

# 対話的に選択
cdi           # fzfでディレクトリを選択
```

## カスタマイズ

### 新しい設定ファイルの追加

1. `myconfig/conf.d/`配下に新しい`.zsh`ファイルを作成

```bash
vim myconfig/conf.d/my_custom.zsh
```

2. 設定を記述（エラーハンドリング推奨）

```zsh
# コマンド存在確認の例
if command -v my_command &>/dev/null; then
    alias mc="my_command --option"
else
    echo "Warning: my_command not installed" >&2
fi
```

3. zshを再起動

```bash
exec zsh
```

**注意:** `myconfig.plugin.zsh`が`conf.d/`配下のすべての`.zsh`ファイルを自動的に読み込みます。

### Powerlevel10kの設定変更

```bash
# 対話的に設定
p10k configure

# 設定後、変更をリポジトリに反映
cp ~/.p10k.zsh /path/to/repo/p10k.zsh
git add p10k.zsh
git commit -m "Change - Update p10k configuration"
```

### プラグインの追加

`zshrc`の`plugins`配列にプラグイン名を追加します。

```zsh
plugins=(
    git
    zsh-autosuggestions
    # ... 既存のプラグイン
    new-plugin  # 追加
)
```

## トラブルシューティング

### zshの起動が遅い

```bash
# 起動時間を測定
time zsh -i -c exit

# プラグイン別の読み込み時間を確認
zmodload zsh/zprof
source ~/.zshrc
zprof
```

詳細は[CLAUDE.md](./CLAUDE.md)の「パフォーマンス最適化」セクションを参照してください。

### コマンドが見つからない

エラーメッセージを確認し、必要なツールをインストールしてください。

```bash
# 例: zoxideがインストールされていない場合
Warning: zoxide not installed, falling back to standard cd
```

### エイリアスが効かない

```bash
# エイリアスの定義を確認
alias | grep target_alias

# 設定を再読み込み
source ~/.zshrc
```

### myconfigプラグインが読み込まれない

```bash
# シンボリックリンクを確認
ls -la ~/.oh-my-zsh/custom/plugins/myconfig

# zshrcのplugins配列を確認
grep "plugins=" ~/.zshrc | grep myconfig
```

## アンインストール

```bash
# シンボリックリンクを削除
rm ~/.zshrc ~/.p10k.zsh
rm ~/.oh-my-zsh/custom/plugins/myconfig

# バックアップを復元（存在する場合）
latest_backup=$(ls -1t ~/.zshrc.backup.* 2>/dev/null | head -1)
[[ -n "$latest_backup" ]] && cp "$latest_backup" ~/.zshrc
```

## 開発・貢献

### ドキュメント

- **[CLAUDE.md](./CLAUDE.md)** - Claude Code用の詳細ガイド、ベストプラクティス
- **[TODO.md](./TODO.md)** - 実施予定のタスク一覧

### コミットメッセージ規約

```
Add - 新機能追加
Change - 既存機能の変更
Fix - バグ修正
Docs - ドキュメント更新
```

### テスト

```bash
# 構文チェック
zsh -n zshrc
zsh -n myconfig/conf.d/*.zsh

# 起動テスト
zsh -i -c "echo 'Startup OK'"
```

## ライセンス

MIT License

## 参考リンク

- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza)

## 変更履歴

### 2025-12-28
- エラーハンドリング追加（zoxide.zsh、eza.zsh、fzf.zsh、PATH.zsh）
- README.md作成
- CLAUDE.md、TODO.md作成

### 2025-12-27
- 設定のモジュール化（myconfig/conf.d/に分割）

### 2025-12-26
- eza移行（exaからの置き換え）
- zsh-completions追加

### 2025-12-25
- zoxide導入（cd/cdr置き換え）

---

**メンテナー:** s-nishio
**最終更新:** 2025-12-28
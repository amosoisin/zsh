# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
# oSee: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-plugins

CONF_D="${HOME}/.oh-my-zsh/custom/plugins/myconfig/conf.d"

# helpers.zshを最初に読み込む（他のファイルでhelper関数を使用するため）
if [[ -f "${CONF_D}/helpers.zsh" ]]; then
    . "${CONF_D}/helpers.zsh"
fi

# 残りの設定ファイルを読み込む（helpers.zshは除外）
for conf in "${CONF_D}"/*.zsh; do
    # helpers.zshは既に読み込み済みなのでスキップ
    [[ "$(basename "$conf")" == "helpers.zsh" ]] && continue
    . "${conf}"
done

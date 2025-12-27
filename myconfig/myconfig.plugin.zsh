# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
# oSee: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization#overriding-and-adding-plugins

CONF_D="${HOME}/.oh-my-zsh/custom/plugins/myconfig/conf.d"

for conf in "${CONF_D}"/*.zsh; do
    . "${conf}"
done

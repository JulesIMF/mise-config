[[ "$OSTYPE" == darwin* ]] || return 0

export HOMEBREW_NO_AUTO_UPDATE=1
if [[ -x /opt/homebrew/bin/brew ]]; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
elif [[ -x /usr/local/bin/brew ]]; then
  path=(/usr/local/bin /usr/local/sbin $path)
fi

# OrbStack's installer owns its PATH and completion integration.
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
path=("${(@u)path}")
fpath=("${(@u)fpath}")

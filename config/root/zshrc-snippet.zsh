# Append to root's zshrc after installing mise system-wide.
# Root's mise config is independent of julesimf's home directory.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
[[ -r /etc/julesimf-shell/modern-root.zsh ]] && source /etc/julesimf-shell/modern-root.zsh

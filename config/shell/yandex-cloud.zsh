# Optional module. The yc installer owns these files, not mise.
_yc_home="$HOME/yandex-cloud"
[[ -r "$_yc_home/path.bash.inc" ]] && source "$_yc_home/path.bash.inc"
# The vendor script calls compinit itself and resets command mappings.
[[ -r "$_yc_home/completion.zsh.inc" ]] && source "$_yc_home/completion.zsh.inc"
unset _yc_home

[[ -r "$HOME/.config/julesimf-shell/modern-option-completion.zsh" ]] && \
  source "$HOME/.config/julesimf-shell/modern-option-completion.zsh"

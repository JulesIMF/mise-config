# Ubuntu desktop only. This file is loaded by base.zsh, not by servers.
[[ -r /etc/os-release ]] && source /etc/os-release
if [[ ${ID-} == ubuntu && -n ${DISPLAY-}${WAYLAND_DISPLAY-} ]] && (( $+commands[xclip] )); then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# Optional module. The yc installer owns these files, not mise.
_yc_home="$HOME/yandex-cloud"
[[ -r "$_yc_home/path.bash.inc" ]] && source "$_yc_home/path.bash.inc"
# This vendor script calls compinit itself; leave it here for now and review
# its startup cost when merging with the Mac configuration.
[[ -r "$_yc_home/completion.zsh.inc" ]] && source "$_yc_home/completion.zsh.inc"
unset _yc_home

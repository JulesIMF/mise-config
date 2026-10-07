# Shared interactive zsh setup. Never source this for non-interactive shells.
[[ -o interactive ]] || return 0

# Keep vendor/user completions outside mise ownership. fpath must precede compinit.
for _dir in "$HOME/.local/share/zsh/site-functions" "$HOME/.zfunc" /opt/homebrew/share/zsh/site-functions; do
  [[ -d "$_dir" ]] && fpath=("$_dir" $fpath)
done
unset _dir
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
setopt globdots
if ! (( $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi

HISTFILE="${HISTFILE:-$HOME/.histfile}"
HISTSIZE=10000
SAVEHIST=100000
bindkey -e

autoload -Uz colors
colors
_julesimf_context=zsh
if [[ -e /.dockerenv || -n ${container-} || -n ${CONTAINER_NAME-} ]]; then
  _julesimf_context="zsh docker ${CONTAINER_NAME:-$(hostname)}"
elif [[ -n ${SSH_CONNECTION-} || -n ${SSH_TTY-} ]]; then
  _julesimf_context="zsh remote $(hostname)"
fi
PROMPT="%B%F{magenta}(${_julesimf_context}) %F{cyan}%n %F{yellow}%~ %f%b%# "
unset _julesimf_context

# Keep a PATH for mise before activation; modern CLI hooks need its shims.
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Legacy variable compatibility plus a fresh date when `today` is invoked.
export today="$(date +%F)"
today() { date +%F; }

_julesimf_copy() {
  if [[ "$OSTYPE" == darwin* ]] && (( $+commands[pbcopy] )); then
    pbcopy
  elif [[ -n ${WAYLAND_DISPLAY-} ]] && (( $+commands[wl-copy] )); then
    wl-copy
  elif [[ -n ${DISPLAY-} ]] && (( $+commands[xclip] )); then
    xclip -selection clipboard
  elif (( $+commands[pbcopy] )); then
    pbcopy
  elif [[ ( -n ${SSH_TTY-} || -e /.dockerenv ) && -t 1 ]] && (( $+commands[base64] )); then
    # OSC 52 fallback depends on terminal and tmux/SSH passthrough support.
    local encoded
    encoded="$(base64 | tr -d '\r\n')" || return 1
    printf '\e]52;c;%s\a' "$encoded" > /dev/tty
  else
    print -u2 'No clipboard backend (pbcopy, wl-copy, xclip or OSC 52).'
    return 1
  fi
}
wdcopy() { print -rn -- "$PWD" | _julesimf_copy; }
pcopy() {
  if (( $# != 1 )); then
    print -u2 'Usage: pcopy <path>'
    return 1
  fi
  print -rn -- "${1:A}" | _julesimf_copy
}
mz() {
  if (( $# != 1 )); then
    print -u2 'Usage: mz <directory>'
    return 1
  fi
  mkdir -p -- "$1" || return
  if (( $+functions[z] )); then z "$1"; else builtin cd -- "$1"; fi
}

# This file is supplied by the always-on conf.d/modern module.
[[ -r "$HOME/.config/julesimf-shell/modern.zsh" ]] && source "$HOME/.config/julesimf-shell/modern.zsh"

# Ubuntu desktop only; absent or ignored on servers, SSH and containers.
if [[ "$OSTYPE" == linux* && ! -e /.dockerenv && -z ${container-} && -z ${CONTAINER_NAME-} && -z ${SSH_CONNECTION-} && -z ${SSH_TTY-} ]]; then
  [[ -r "$HOME/.config/julesimf-shell/ubuntu-desktop.zsh" ]] && source "$HOME/.config/julesimf-shell/ubuntu-desktop.zsh"
fi

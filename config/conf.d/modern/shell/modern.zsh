# Optional CLI integrations. All commands are checked at shell startup.
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd z)"
fi
if (( $+commands[broot] )); then
  eval "$(broot --print-shell-function zsh)"
fi
if (( $+commands[atuin] )); then
  # Atuin takes Up and Ctrl+R after fzf initializes.
  eval "$(atuin init zsh)"
fi

# Keep familiar interactive shortcuts without breaking standard grep/find/cd.
if (( $+commands[eza] )); then
  alias eza='eza --hyperlink=auto'
  alias ls='eza --hyperlink=auto'
fi
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[dust] )) && alias du='dust'
(( $+commands[duf] )) && alias df='duf'
(( $+commands[btop] )) && alias htop='btop'
(( $+commands[rg] )) && alias ag='rg'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
(( $+commands[colordiff] )) && alias diff='colordiff'
(( $+commands[tree] )) && alias tree='tree -C'
(( $+commands[highlight] )) && alias hl='highlight --out-format xterm256'
if (( $+commands[ip] )) && [[ "$OSTYPE" == linux* ]]; then
  alias ip='ip -color=auto'
fi
# Older system xxd versions have no color option.
if (( $+commands[xxd] )) && [[ "$(command xxd -h 2>&1)" == *'-R when'* ]]; then
  alias xxd='xxd -R always'
fi

[[ -r "$HOME/.config/julesimf-shell/modern-option-completion.zsh" ]] && \
  source "$HOME/.config/julesimf-shell/modern-option-completion.zsh"

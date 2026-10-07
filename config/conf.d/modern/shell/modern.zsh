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
  # Keep the Up arrow; Atuin takes Ctrl+R after fzf initializes.
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# Keep familiar interactive shortcuts without breaking standard grep/find/cd.
(( $+commands[eza] )) && alias ls='eza --hyperlink=auto'
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[dust] )) && alias du='dust'
(( $+commands[duf] )) && alias df='duf'
(( $+commands[btop] )) && alias htop='btop'
(( $+commands[rg] )) && alias ag='rg'

[[ -r "$HOME/.config/julesimf-shell/modern-option-completion.zsh" ]] && \
  source "$HOME/.config/julesimf-shell/modern-option-completion.zsh"

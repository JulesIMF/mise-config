# Root-only shell fragment.
# Use only globally available executables; never source the user's home config.
[[ -o interactive ]] || return 0
if ! (( $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi
(( $+commands[eza] )) && alias ls='eza --hyperlink=auto'
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[dust] )) && alias du='dust'
(( $+commands[duf] )) && alias df='duf'
(( $+commands[btop] )) && alias htop='btop'
(( $+commands[rg] )) && alias ag='rg'
[[ -r /etc/julesimf-shell/modern-option-completion.zsh ]] && \
  source /etc/julesimf-shell/modern-option-completion.zsh

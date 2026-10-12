# Optional completions for tools installed by the modern-extra profile.
# compinit has already run in base.zsh; leave existing vendor completions alone.
if (( $+commands[dua] && $+functions[compdef] )) && [[ -z ${_comps[dua]-} ]]; then
  if _dua_completion="$(dua completions zsh 2>/dev/null)"; then
    eval "$_dua_completion"
  fi
  unset _dua_completion
fi

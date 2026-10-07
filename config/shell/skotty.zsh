# Optional module; preserve the requested skotty integration verbatim in spirit.
if (( $+commands[skotty] )); then
  eval "$(skotty ssh env)"
fi

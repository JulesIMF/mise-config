# Kept separate from tool initialization. Existing dedicated completions win.
(( $+functions[compdef] )) || return 0
for _modern_cli in fzf difft btop eza bat dust duf; do
  if (( $+commands[$_modern_cli] )) && [[ -z ${_comps[$_modern_cli]-} ]]; then
    for _completion_dir in $fpath; do
      if [[ -r "$_completion_dir/_$_modern_cli" ]]; then
        compdef "_$_modern_cli" "$_modern_cli"
        break
      fi
    done
    [[ -n ${_comps[$_modern_cli]-} ]] || compdef _gnu_generic "$_modern_cli"
  fi
done
unset _modern_cli _completion_dir

# zsh's bundled SCCS completion may claim `delta`.
if (( $+commands[delta] )); then
  if [[ -r "$HOME/.zfunc/_delta" ]]; then
    compdef _delta delta
  else
    compdef _gnu_generic delta
  fi
fi

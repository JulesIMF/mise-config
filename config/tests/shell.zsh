[[ -o interactive ]] || { print -u2 'Run this test from interactive zsh.'; exit 1; }
setopt errexit

_shell_test_fail() { print -u2 -- "FAIL: $1"; exit 1; }

[[ "$HISTFILE" == "$HOME/.histfile" ]] || _shell_test_fail HISTFILE
[[ "$HISTSIZE" == 10000 && "$SAVEHIST" == 100000 ]] || _shell_test_fail history-size
[[ -o globdots ]] || _shell_test_fail globdots
[[ "$(today)" == "$(date +%F)" && "$today" == "$(date +%F)" ]] || _shell_test_fail today
[[ "${aliases[ls]-}" == 'eza --hyperlink=auto' ]] || _shell_test_fail ls
[[ "${aliases[eza]-}" == 'eza --hyperlink=auto' ]] || _shell_test_fail eza
[[ "${aliases[cat]-}" == 'bat --paging=never --style=plain' ]] || _shell_test_fail cat
[[ "${aliases[grep]-}" == 'grep --color=auto' ]] || _shell_test_fail grep
[[ "$(bindkey '^[[A')" == *atuin-up-search* ]] || _shell_test_fail atuin-up
[[ "$(bindkey '^R')" == *atuin-search* ]] || _shell_test_fail atuin-ctrl-r
(( $+functions[br] && $+functions[z] && $+functions[compdef] )) || _shell_test_fail integrations
[[ "${functions_source[br]-}" != *launcher/bash* ]] || _shell_test_fail broot-native-zsh
[[ -n "${_comps[eza]-}" && -n "${_comps[delta]-}" ]] || _shell_test_fail modern-completions

if [[ "$OSTYPE" == darwin* ]]; then
  [[ "${aliases[ip]-}" != *-color* ]] || _shell_test_fail iproute2mac
  [[ "$HOMEBREW_NO_AUTO_UPDATE" == 1 ]] || _shell_test_fail homebrew
  [[ "$(whence -p curl)" == /opt/homebrew/opt/curl/bin/curl ]] || _shell_test_fail brew-curl
  [[ "$(whence -p btop)" == /opt/homebrew/opt/btop/bin/btop ]] || _shell_test_fail brew-btop
  if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
    [[ "${path[(Ie)$HOME/.orbstack/bin]}" != 0 ]] || _shell_test_fail orbstack-path
    [[ "${fpath[(Ie)/Applications/OrbStack.app/Contents/MacOS/../Resources/completions/zsh]}" != 0 ]] || _shell_test_fail orbstack-completion
  fi
fi

_shell_test_clipboard="$(mktemp)"
_shell_test_directory="$(mktemp -d)"
_shell_test_original_pwd="$PWD"
_shell_test_original_copy="$functions[_julesimf_copy]"
_shell_test_cleanup() {
  builtin cd -- "$_shell_test_original_pwd"
  functions[_julesimf_copy]="$_shell_test_original_copy"
  command rm -f -- "$_shell_test_clipboard"
  [[ ! -d "$_shell_test_directory/nested" ]] || command rmdir -- "$_shell_test_directory/nested"
  command rmdir -- "$_shell_test_directory"
}
trap _shell_test_cleanup EXIT

# Shadow the backend, not the user's system clipboard.
_julesimf_copy() { command cat > "$_shell_test_clipboard"; }
wdcopy
[[ "$(command cat "$_shell_test_clipboard")" == "$PWD" ]] || _shell_test_fail wdcopy
pcopy .
[[ "$(command cat "$_shell_test_clipboard")" == "$PWD" ]] || _shell_test_fail pcopy
if pcopy >/dev/null 2>&1; then _shell_test_fail pcopy-arity; fi
if mz >/dev/null 2>&1; then _shell_test_fail mz-arity; fi
mz "$_shell_test_directory/nested"
[[ "$PWD" == "$_shell_test_directory/nested" ]] || _shell_test_fail mz

_shell_test_cleanup
trap - EXIT
unfunction _shell_test_cleanup _shell_test_fail
unset _shell_test_clipboard _shell_test_directory _shell_test_original_pwd _shell_test_original_copy
print 'PASS: shared shell, aliases, Atuin, clipboard helpers and mz'

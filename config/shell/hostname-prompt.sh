# Sourced by the optional hostname-prompt profile in interactive zsh or bash.
case $- in *i*) ;; *) return 0 ;; esac

if [ -z "${JULESIMF_PROMPT_HOSTNAME:-}" ]; then
  JULESIMF_PROMPT_HOSTNAME=$(hostname 2>/dev/null) ||
    JULESIMF_PROMPT_HOSTNAME=${HOSTNAME:-${HOST:-unknown}}
fi
export JULESIMF_PROMPT_HOSTNAME

if [ -n "${ZSH_VERSION:-}" ]; then
  if (( $+functions[_julesimf_set_prompt] )); then
    _julesimf_set_prompt
  fi
elif [ -n "${BASH_VERSION:-}" ]; then
  if [ -z "${_JULESIMF_BASH_BASE_PS1+x}" ]; then
    _JULESIMF_BASH_BASE_PS1=$PS1
  fi
  PS1="(bash ${JULESIMF_PROMPT_HOSTNAME}) ${_JULESIMF_BASH_BASE_PS1}"
fi

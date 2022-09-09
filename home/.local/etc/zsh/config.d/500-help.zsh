# shellcheck shell=bash

if [[ ! -o interactive ]]; then
  return 0
fi

alias run-help >&/dev/null && unalias run-help
autoload run-help
alias help=run-help

# vim: filetype=zsh

# shellcheck shell=bash

# TODO - Does not seem to be working!

if ! which terraform > /dev/null; then
  return 0
fi

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

complete -o nospace -C terraform terraform

# vim: filetype=zsh

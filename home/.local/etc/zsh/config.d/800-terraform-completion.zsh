# shellcheck shell=bash


if ! terraform version > /dev/null 2>&1; then
# if ! command -v terraform > /dev/null; then
  return 0
fi

# Only init bashcompinit once
if ! whence -w complete > /dev/null 2>&1; then
  autoload -U +X bashcompinit && bashcompinit
fi

complete -o nospace -C terraform terraform

# vim: filetype=zsh

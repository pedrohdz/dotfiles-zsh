# shellcheck shell=bash

# Complete <tool>-<account> symlinks to agent-vault-wrapper (gh-drounin, ...)
# as the underlying tool, without starting a vault session. The helper is in
# site-functions/_agent_vault_wrapper_tool. Links are discovered here, so a new
# <tool>-<account> symlink needs no list to maintain.

autoload -Uz _agent_vault_wrapper_tool

# The wrapper's own installed link resolves to itself, so skip it: it is not a
# <tool>-<account> name.
for _f in ~/.local/bin/*(N@); do
  if [[ ${_f:t} != agent-vault-wrapper && ${_f:A:t} == agent-vault-wrapper ]]; then
    compdef _agent_vault_wrapper_tool "${_f:t}"
  fi
done
unset _f

# vim: filetype=zsh

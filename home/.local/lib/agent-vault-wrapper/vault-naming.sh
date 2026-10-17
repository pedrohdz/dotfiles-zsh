# shellcheck shell=bash
# shellcheck disable=SC2034  # variables here are read by the sourcing scripts
#
# vault-naming.sh -- sourced, never executed.
#
# Agent Vault vault names are <account>-<purpose>-<access>. This file is the
# single definition of that format and its vocabulary, so a rename is an edit
# here. agent-vault-wrapper sources it for symlink mode, and agent-harness-
# wrapper will source it to pick the vault an agent harness runs under.
#
# Build names with vault_name; do not split them apart. An account name may
# itself contain dashes, so a name cannot be parsed back reliably.

# Purpose: who the vault is for.
VAULT_PURPOSE_AGENT=agent    # an agent harness runs under it
VAULT_PURPOSE_USER=user      # a person's own tools run under it

# Access: how much the credentials in the vault can do.
VAULT_ACCESS_READONLY=read-only    # to become "readonly" with the vault rename
VAULT_ACCESS_FULL=full

# What agent-vault-wrapper's symlink mode (gh-<account>, ...) uses. Stopgap:
# borrow the read-only agent vaults until the user/full vaults exist, then
# switch these to VAULT_PURPOSE_USER and VAULT_ACCESS_FULL.
WRAPPER_DEFAULT_PURPOSE=$VAULT_PURPOSE_AGENT
WRAPPER_DEFAULT_ACCESS=$VAULT_ACCESS_READONLY

# vault_name <account> <purpose> <access>
vault_name() {
  printf '%s-%s-%s' "$1" "$2" "$3"
}

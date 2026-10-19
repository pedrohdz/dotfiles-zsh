# shellcheck shell=bash
# shellcheck disable=SC2034  # variables here are read by the sourcing scripts
#
# vault-naming.sh -- sourced, never executed.
#
# Agent Vault vault names are <account>-<purpose>-<access>. This file is the
# single definition of that format and its vocabulary, so a rename is an edit
# here. agent-vault-wrapper sources it for symlink mode, and agent-harness-
# wrapper sources it to pick the vault an agent harness runs under.
#
# Build names with vault_name; do not split them apart. An account name may
# itself contain dashes, so a name cannot be parsed back reliably.

# Purpose: who the vault is for.
VAULT_PURPOSE_AGENT=agent    # an agent harness runs under it
VAULT_PURPOSE_USER=user      # a person's own tools run under it

# Access: how much the credentials in the vault can do.
VAULT_ACCESS_READONLY=read-only    # to become "readonly" with the vault rename
VAULT_ACCESS_FULL=full

# What agent-vault-wrapper's symlink mode (gh-<account>, ...) uses: a
# person's own tools get the account's user vault with full access. Agent
# harnesses do not use these; agent-harness-wrapper names the read-only agent
# vault itself.
WRAPPER_DEFAULT_PURPOSE=$VAULT_PURPOSE_USER
WRAPPER_DEFAULT_ACCESS=$VAULT_ACCESS_FULL

# vault_name <account> <purpose> <access>
vault_name() {
  printf '%s-%s-%s' "$1" "$2" "$3"
}

#! /usr/bin/env bash

# set -o pipefail
# set -o nounset
# set -o errexit

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  echo "ERROR - $0: must be sourced, not executed"
  exit 1
fi

node_path="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"
node_bin_path="$node_path/bin"
npmrc_path="$node_path/npmrc"

#----
# Sanity checks
#----
if [ -n "$NPM_CONFIG_USERCONFIG" ]; then
  echo "ERROR - NPM_CONFIG_USERCONFIG is already set: $NPM_CONFIG_USERCONFIG"
  return 1
fi

if echo "$PATH" | grep "$node_bin_path"; then
  echo "ERROR - Path was already updated"
  return 1
fi


#----
# Setup
#----
if [ ! -f "$npmrc_path" ]; then
  echo "Creating: $npmrc_path"
  echo "prefix = $node_path" > "$npmrc_path"
fi

export PATH="$node_bin_path:$PATH"
export NPM_CONFIG_USERCONFIG="$npmrc_path"
source <("$node_bin_path/npm" completion)


#----
# Clean up
#----
echo "PATH:                  $node_bin_path:..."
echo "NPM_CONFIG_USERCONFIG: $NPM_CONFIG_USERCONFIG"

unset node_path node_bin_path npmrc_path
return 0

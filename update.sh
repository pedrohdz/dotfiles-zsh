#!/bin/sh

set -o nounset
set -o errexit
set -o pipefail



homeshick_dot_name=$(basename "$(cd "$(dirname "$0")" ; pwd -P)")

git pull --rebase
git submodule foreach git checkout master
git submodule foreach git clean -f
git submodule foreach git pull --rebase
git status

find ~/.vim -xtype l -print -delete

echo "Updating Homeshick links for '$homeshick_dot_name', this might take a while..."
"${HOME}/.homesick/repos/homeshick/bin/homeshick" link "$homeshick_dot_name"

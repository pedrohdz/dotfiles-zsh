# shellcheck shell=bash

if which nvim > /dev/null; then
  _editor=$(which nvim)
  export EDITOR="$_editor"
  export VISUAL="$_editor"
elif which vim > /dev/null; then
  _editor=$(which vim)
  export EDITOR="$_editor"
  export VISUAL="$_editor"
fi
unset _editor

if which less > /dev/null; then
  _pager=$(which less)
  export PAGER="$_pager"
  export MANPAGER="$_pager -is"
  unset _pager
fi

export MYSQL_HOME=${HOME}/.mysql
export P4CONFIG=.p4config
export WATCH_INTERVAL=1

# export PYTHONSTARTUP="${HOME}/.pystartup"

# vim: filetype=bash

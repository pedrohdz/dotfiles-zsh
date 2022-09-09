# shellcheck shell=bash

if which dircolors > /dev/null; then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'

  export LESS="-RX --use-color $LESS"
fi

alias ll='ls -lF'
alias la='ls -laF'
alias l='ls -CF'
alias g='grep -sIr'

alias qs="date +%Y%m%d"
alias qsl="date +%Y%m%d_%H%M"
alias pause='read -n 1 -s -r -p "Press any key to continue..."; echo'
alias wget-continue='wget --tries=50 --continue --waitretry=2'

alias cleanbackups='find . -name "*~" -exec rm -v \{\} \;'

if which python > /dev/null; then
  alias jsonpp='python -m json.tool'
fi

# vim: filetype=bash

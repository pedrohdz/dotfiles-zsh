# shellcheck shell=bash

if [[ ! (-o interactive || $- == *i*) ]]; then
  return 0
fi

if which dircolors > /dev/null; then
  eval "$(dircolors -b ~/.local/etc/shell-common/dircolors)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'

  export LESS='--RAW-CONTROL-CHARS --no-init --use-color'
fi

alias ll='ls -lF'
alias la='ls -laF'
alias l='ls -CF'
alias g='grep -sIr'

alias qs="date +%Y%m%d"
alias qsl="date +%Y%m%d_%H%M"
alias pause='read -n 1 -s -r -p "Press any key to continue..."; echo'
alias wget-continue='wget --tries=50 --continue --waitretry=2'

# Cleanup commands
alias cbackups='find . -name "*~" -exec rm -v \{\} \;'
alias chomeshick='find ~/.vim ~/.ssh ~/.local ~/.config ~/.tmux -xtype l -print -delete'

if which python > /dev/null; then
  alias jsonpp='python -m json.tool'
fi

_ignore="$HOME/.config/fd/ignore"
if which rg > /dev/null && [[ -e "$_ignore" ]]; then
  # shellcheck disable=SC2139
  alias rg="rg --ignore-file=$_ignore"
fi
unset _ignore

# vim: filetype=bash

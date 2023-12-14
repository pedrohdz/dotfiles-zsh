# shellcheck shell=bash

if ! which sgpt > /dev/null; then
  return 0
fi

sgpt-repl() {
  if [[ "$1" != --* ]]; then
    sgpt --repl "${1:-temp}" --shell
  else
    echo "ERROR: '$1' is not a chat name!"
    return 1
  fi
}

sgpt-nvim() {
  if [[ "$1" != --* ]]; then
    sgpt --chat "${1:-temp}" --editor
  else
    echo "ERROR: '$1' is not a chat name!"
    return 1
  fi
}


#------------------------------------------------------------------------------
# *Notes to self (Pedro)*
#
# The original version below was pulled with:
#   ````
#   wget https://raw.githubusercontent.com/TheR1D/shell_gpt/shell-integrations/simple_zsh.sh
#   ````
#
# More information can be found in:
#   - https://github.com/TheR1D/shell_gpt#shell-integration
#------------------------------------------------------------------------------
# Shell-GPT integration ZSH v0.1
_sgpt_zsh() {
  if [[ -n "$BUFFER" ]]; then
    _sgpt_prev_cmd=$BUFFER
    BUFFER+=" 󰶡"
    zle -I && zle redisplay
    BUFFER=" $(sgpt --shell <<< "$_sgpt_prev_cmd")"
    zle end-of-line
  fi
}
zle -N _sgpt_zsh
bindkey '\C-y' _sgpt_zsh
# Shell-GPT integration ZSH v0.1

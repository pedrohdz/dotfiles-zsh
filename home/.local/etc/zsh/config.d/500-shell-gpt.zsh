#------------------------------------------------------------------------------
# *Notes to self (Pedro)*
#
# The original version of this file was pulled with:
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
    BUFFER="$(sgpt --shell <<< $_sgpt_prev_cmd)"
    zle end-of-line
  fi
}
zle -N _sgpt_zsh
bindkey '\C-y' _sgpt_zsh
# Shell-GPT integration ZSH v0.1

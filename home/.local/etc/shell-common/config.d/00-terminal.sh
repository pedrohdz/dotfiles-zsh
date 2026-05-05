# shellcheck shell=bash

if [[ ! (-o interactive || $- == *i*) ]]; then
  return 0
fi


#------------------------------------------------------------------------------
# Handle terminal vars over SSH
#------------------------------------------------------------------------------
# Sync TERM_PROGRAM/COLORTERM ↔ LC__* for SSH passthrough — LC_* is widely
# accepted via AcceptEnv where arbitrary vars are not. See:
#   ~/.ssh/configs/common.sshconfig
export LC__TERMINAL=${LC__TERMINAL:-$TERM_PROGRAM}
export LC__TERMINAL_VERSION=${LC__TERMINAL_VERSION:-$TERM_PROGRAM_VERSION}
export LC__COLORTERM=${LC__COLORTERM:-$COLORTERM}

export TERM_PROGRAM=${TERM_PROGRAM:-$LC__TERMINAL}
export TERM_PROGRAM_VERSION=${TERM_PROGRAM_VERSION:-$LC__TERMINAL_VERSION}
export COLORTERM=${COLORTERM:-$LC__COLORTERM}


#------------------------------------------------------------------------------
# WezTerm
#------------------------------------------------------------------------------
# https://wezterm.org/config/lua/config/term.html
if [[ "$TERM" == "wezterm" ]]; then
  export COLORTERM=truecolor
  if infocmp wezterm &>/dev/null; then
    :
  elif infocmp xterm-direct &>/dev/null; then
    export TERM=xterm-direct
  elif infocmp xterm-256color &>/dev/null; then
    export TERM=xterm-256color
  fi
  return
fi


#------------------------------------------------------------------------------
# Truecolor check for all else
#------------------------------------------------------------------------------
if [[ -n "$COLORTERM" ]]; then
  return
fi

case "$TERM" in
  *-direct)
    export COLORTERM=truecolor ;;
  tmux*|screen*)
    :
    ;;
  *)
    case "${TERM_PROGRAM-}" in
      iTerm.app|vscode)
        export COLORTERM=truecolor
        ;;
    esac
    ;;
esac

# shellcheck shell=bash

if [[ ! (-o interactive || $- == *i*) ]]; then
  return 0
fi

echo "TERM         = $TERM"
echo "COLORTERM    = $COLORTERM"
echo "TERM_PROGRAM = $TERM_PROGRAM"

#------------------------------------------------------------------------------
# Handle terminal vars over SSH
#------------------------------------------------------------------------------
export LC_TERMINAL=${LC_TERMINAL:-$TERM_PROGRAM}
export LC_TERMINAL_VERSION=${LC_TERMINAL_VERSION:-$TERM_PROGRAM_VERSION}
export LC_COLORTERM=${LC_COLORTERM:-$COLORTERM}

export TERM_PROGRAM=${TERM_PROGRAM:-$LC_TERMINAL}
export TERM_PROGRAM_VERSION=${TERM_PROGRAM_VERSION:-$LC_TERMINAL_VERSION}
export COLORTERM=${COLORTERM:-$LC_COLORTERM}


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

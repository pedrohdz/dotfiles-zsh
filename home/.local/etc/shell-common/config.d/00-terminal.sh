# shellcheck shell=bash

if [[ ! (-o interactive || $- == *i*) ]]; then
  return 0
fi

# If TERM=wezterm but the official terminfo is not installed, fall back to
# xterm-256color so the shell stays usable until `home-manager switch` is run.
# The ncurses-bundled wezterm entry lacks extended capabilities and causes
# broken colors and garbled input.
#   https://wezterm.org/config/lua/config/term.html
if [[ "$TERM" == "wezterm" ]] && ! infocmp wezterm &>/dev/null; then
  export TERM=xterm-256color
fi

# Set COLORTERM=truecolor if the terminal supports it and has not already
# declared it.  tmux/screen are skipped — tmux-256color carries truecolor
# support via the Tc terminfo capability rather than COLORTERM.
if [[ -z "$COLORTERM" ]]; then
  case "$TERM" in
    wezterm|*-direct)
      export COLORTERM=truecolor ;;
    tmux*|screen*)
      : ;;
    *)
      case "${TERM_PROGRAM-}" in
        WezTerm|iTerm.app) export COLORTERM=truecolor ;;
      esac ;;
  esac
fi

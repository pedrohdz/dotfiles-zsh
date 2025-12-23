source ~/.profile

case "$-" in
  *i*)
    # Only run .bashrc in interactive shells!
    [ -f "$HOME/.bashrc" ] \
      && source "$HOME/.bashrc"
    ;;
esac

autoload -Uz add-zsh-hook

function __phdz_update_term_title() {
  [[ -o interactive ]] && [[ $TERM != dumb ]] \
    && print -Pn "\e]0;%n@%m: %~\a"
}

add-zsh-hook chpwd  __phdz_update_term_title
add-zsh-hook precmd __phdz_update_term_title

__phdz_update_term_title

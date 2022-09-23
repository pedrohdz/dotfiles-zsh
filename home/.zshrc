# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


fpath=( \
  $HOME/.homesick/repos/homeshick/completions \
  $HOME/.local/share/zsh/site-functions \
  /opt/devenv/share/zsh/site-functions \
  $fpath \
)

#------------------------------------------------------------------------------
# Trying out McFly
#------------------------------------------------------------------------------
# eval "$(mcfly init zsh)"
# export MCFLY_KEY_SCHEME=vim
# export MCFLY_FUZZY=2
# export MCFLY_RESULTS=50


#------------------------------------------------------------------------------
# Antigen
#------------------------------------------------------------------------------
source ~/.local/lib/zsh/antigen/antigen.zsh

antigen theme romkatv/powerlevel10k
antigen bundle vi-mode
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle mfaerevaag/wd

# TODO:
#  - https://github.com/Aloxaf/fzf-tab
#  - sgpthomas/zsh-up-dir - Love the idea, does not work woth p10k. :-(  Look
#    at https://github.com/romkatv/powerlevel10k/issues/72

# Plugin fails:
#  - jeffreytse/zsh-vi-mode - NEVER use again.  Messes with cursor
#  - softmoth/zsh-vim-mode - Fails to load
#  - zsh-users/zsh-syntax-highlighting - terrible performance and buggy

antigen apply


#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
#bindkey -v
setopt hist_ignore_space

setopt bash_autolist
setopt no_share_history
unsetopt correct_all
setopt +o nomatch

# This binds Up and Down arrow keys.
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward


#------------------------------------------------------------------------------
# fzf
#------------------------------------------------------------------------------
if which fzf > /dev/null; then
  export FZF_DEFAULT_OPTS='--height 40%'
  export FZF_COMPLETION_OPTS='--height 40% --reverse --info=inline'
  export FZF_CTRL_T_OPTS=$FZF_COMPLETION_OPTS
  export FZF_CTRL_R_OPTS=$FZF_COMPLETION_OPTS
  if which fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='command fd --hidden --follow --exclude .git'

    _fzf_compgen_path() {
      command fd --hidden --follow --exclude '.git' . "$1"
    }

    _fzf_compgen_dir() {
      command fd --type d --hidden --follow --exclude '.git' . "$1"
    }
  fi
fi


#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------
# Thank you: https://github.com/scriptingosx/dotfiles/blob/master/zshfunctions/update_terminal_pwd
function update_terminal_cwd()
{
  # Percent-encode the pathname.
  local url_path=''
  {
    # Use LC_CTYPE=C to process text byte-by-byte. Ensure that
    # LC_ALL isn't set, so it doesn't interfere.
    local i ch hexch LC_CTYPE=C LC_ALL=
    for (( i = 1; i <= ${#PWD}; ++i)); do
      ch="$PWD[i]"
      if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
        url_path+="$ch"
      else
        printf -v hexch "%02X" "'$ch"
        # printf treats values greater than 127 as
        # negative and pads with "FF", so truncate.
        url_path+="%${hexch: -2:2}"
      fi
    done
  }

  printf '\033]2;%s - %s\07' "${USER}@${HOST}" "$url_path"
}

function _source_includes()
{
  local _local_prefix
  if which port > /dev/null; then
    _local_prefix=$(dirname "$(dirname "$(which port)")")
  else
    _local_prefix='/usr/local'
  fi

  # local _brew_prefix
  # if which brew > /dev/null; then
  #   _brew_prefix=$(brew --prefix)
  # else
  #   _brew_prefix='/DOES/NOT/EXIST'
  # fi

  local _includes
  _includes=( \
    $HOME/.p10k.zsh \
    $HOME/.local/etc/shell-common/config.d/*.sh \
    $HOME/.local/etc/zsh/config.d/*.zsh \
    $HOME/.homesick/repos/homeshick/homeshick.sh \
    $_local_prefix/share/fzf/shell/key-bindings.zsh \
    $_local_prefix/share/fzf/shell/completion.zsh \
  )

  for _file in "${_includes[@]}"; do
    if [[ -f $_file ]]; then
      #echo "Processing: $_file"
      source "$_file"
    fi
  done
}

_source_includes
add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd


#==============================================================================
# Completion
#==============================================================================
# Warning - Must run after `dircolors` to load `LS_COLORS`.
# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' menu yes=long select=0
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' verbose true
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit


#------------------------------------------------------------------------------
# BS gaurd
#------------------------------------------------------------------------------
# Stop processing at this point!
return 0

#autoload -U +X bashcompinit && bashcompinit
#complete -o nospace -C /opt/devenv/bin/terraform terraform

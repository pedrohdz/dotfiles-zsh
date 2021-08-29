# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

#------------------------------------------------------------------------------
# Antigen
#------------------------------------------------------------------------------
source ~/.local/lib/zsh/antigen/antigen.zsh

antigen theme romkatv/powerlevel10k
antigen bundle vi-mode
antigen bundle zsh-users/zsh-autosuggestions

# TODO:
#  - https://github.com/Aloxaf/fzf-tab

# Plugin fails:
#  - jeffreytse/zsh-vi-mode - NEVER use again.  Messes with cursor
#  - softmoth/zsh-vim-mode - Fails to load
#  - zsh-users/zsh-syntax-highlighting - terrible performance and buggy

antigen apply


#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=2500
#bindkey -v

setopt bash_autolist
setopt no_share_history

bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward


if which vim > /dev/null; then
  export EDITOR="$(which vim)"
  export VISUAL="$(which vim)"
fi

if which less > /dev/null; then
  export PAGER="$(which less)"
  export LESS="-F -X $LESS"
  export MANPAGER="$(which less) -is"
fi


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
# Aliases
#------------------------------------------------------------------------------
if which dircolors > /dev/null; then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'

  export LESS="--use-color $LESS"
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

if which VBoxManage > /dev/null; then
  alias vbm=$vbm_location
fi

if which python > /dev/null; then
  alias jsonpp='python -m json.tool'
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

function py-activate()
{
  # Is there a local virtualenv
  local l_activate="$PWD/.venv/bin/activate"
  if [ ! -e "$l_activate" ]; then
    echo "ERROR - Could not find '$l_activate'"
    return 1
  fi

  echo "Activating: $l_activate"
  source "$l_activate"
  if [ $? -ne 0 ]; then
    echo "ERROR - Failed to exectute '$l_activate'"
    return 1
  fi
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
    "$HOME/.p10k.zsh" \
    "$HOME/.homesick/repos/homeshick/homeshick.sh" \
    "$_local_prefix/share/fzf/shell/key-bindings.zsh" \
    "$_local_prefix/share/zsh/site-functions/_fzf" \  # Broken, does not get loaded with $fpath, so sourcing directly
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
# Zsh managed
#==============================================================================
# Warning - Must run after `dircolors` to load `LS_COLORS`.
# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '+' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/Users/pedro/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


#------------------------------------------------------------------------------
# BS gaurd
#------------------------------------------------------------------------------
# Stop processing at this point!
return 0

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#==============================================================================
# Zsh managed
#==============================================================================
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
# Configuration
#------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=2500
#bindkey -v

bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward


if which vim > /dev/null; then
  export EDITOR="$(which vim)"
  export VISUAL="$(which vim)"
fi

if which less > /dev/null; then
  export PAGER="$(which less)"
  export MANPAGER="$(which less) -is"
fi


#------------------------------------------------------------------------------
# Antigen
#------------------------------------------------------------------------------
source ~/.local/lib/zsh/antigen/antigen.zsh
antigen use oh-my-zsh  # TODO - Can we remove this? Loads the oh-my-zsh's library.

antigen theme romkatv/powerlevel10k

antigen bundle aws
antigen bundle command-not-found
antigen bundle git
antigen bundle kubectl
antigen bundle kubectx
antigen bundle macports
antigen bundle minikube
antigen bundle nmap
antigen bundle osx
antigen bundle pip
antigen bundle terraform
antigen bundle tmux
antigen bundle vi-mode

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
#antigen bundle jeffreytse/zsh-vi-mode  # NEVER use again.  Messes with cursor
#antigen bundle softmoth/zsh-vim-mode  # TODO - Fails to load

antigen apply


#------------------------------------------------------------------------------
# Includes
#------------------------------------------------------------------------------
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

fpath=($HOME/.homesick/repos/homeshick/completions $fpath)


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

add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd


#------------------------------------------------------------------------------
# BS gaurd
#------------------------------------------------------------------------------
# Stop processing at this point!
return 0

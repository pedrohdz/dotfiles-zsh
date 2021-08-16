# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
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
antigen use oh-my-zsh

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

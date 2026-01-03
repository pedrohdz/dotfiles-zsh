# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#------------------------------------------------------------------------------
# Update fpath
#------------------------------------------------------------------------------
# TODO - Should we drop the lines with $ZSH_VERSION completely?
function
{
  local _port_prefix
  if which port > /dev/null; then
    _port_prefix=$(dirname "$(dirname "$(which port)")")
  else
    _port_prefix="/opt/local"
  fi

  # Nix Profiles
  _nix_profiles=("${(@Oa)${(s: :)NIX_PROFILES}}")  # Splits and reverses order
  local _nix_profiles_fpaths=()
  local _nix_profile
  for _nix_profile in "${_nix_profiles[@]}"; do
    _nix_profiles_fpaths+=(
      "$_nix_profile/share/zsh/site-functions"
      # "$_nix_profile/share/zsh/$ZSH_VERSION/functions"
    )
  done

  # Paths
  local _paths=(
    "${_nix_profiles_fpaths[@]}"
    "$HOME/.homesick/repos/homeshick/completions"
    "$HOME/.local/share/zsh/site-functions"
    "/opt/devenv/share/zsh/site-functions"
    # "/opt/devenv/share/zsh/$ZSH_VERSION/functions"
    "${_port_prefix:+$_port_prefix/share/zsh/site-functions}"
    # "${_port_prefix:+$_port_prefix/share/zsh/$ZSH_VERSION/functions}"
    "/usr/local/share/zsh/site-functions"
    # "/usr/local/share/zsh/$ZSH_VERSION/functions"
    "/usr/share/zsh/site-functions"
    # "/usr/share/zsh/$ZSH_VERSION/functions"
  )

  # Build the initial list
  local _new_fpath=()
  local _dir
  for _dir in "${_paths[@]}"; do
    if [[ -n "$_dir" ]] && [[ -d "$_dir" ]]; then
      _new_fpath+=("$_dir")
    fi
  done

  # Append original fpath values if they are not already in _new_fpath.
  for _dir in "${fpath[@]}"; do
    if (( ! $_new_fpath[(Ie)$_dir] )) && [[ -d "$_dir" ]]; then
      _new_fpath+=("$_dir")
    fi
  done

  # Replace fpath
  fpath=("${_new_fpath[@]}")
}


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
# Functions
#------------------------------------------------------------------------------
# Source common includes
function {
  local _includes
  _includes=( \
    $HOME/.p10k.zsh \
    $HOME/.local/etc/shell-common/config.d/*.sh \
    $HOME/.local/etc/zsh/config.d/*.zsh \
    $HOME/.homesick/repos/homeshick/homeshick.sh \
  )

  for _file in "${_includes[@]}"; do
    if [[ -f $_file ]]; then
      # echo "Processing: $_file"
      source "$_file"
    fi
  done
}


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
# BS gaurd - Anything after this was added by something else
#------------------------------------------------------------------------------
# Stop processing at this point!
return 0
#------------------------------------------------------------------------------

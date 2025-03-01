DIRSTACKSIZE=20
setopt autopushd pushdsilent pushdtohome # pushdminus 



function __phdz_load_color_variables()
{
  if ! which tput > /dev/null 2>&1; then
    return
  fi

  if [[ $(tput -T"$TERM" colors) -lt 8 ]]; then
    return
  fi

  # Read up on:
  #   - http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
  #   - http://www.termsys.demon.co.uk/vtansi.htm#colors  (Historical)

  if [[ -z ${__phdz_txt_attr+x} ]]; then
    declare -gA __phdz_txt_attr
    __phdz_txt_attr['bold']=$(tput bold)
    __phdz_txt_attr['underline']=$(tput smul)
    __phdz_txt_attr['dim']=$(tput dim)
    __phdz_txt_attr['rev']=$(tput rev)
    __phdz_txt_attr['CLEAR']=$(tput sgr0)
  fi

  if [[ -z ${__phdz_txt_color+x} ]]; then
    declare -gA __phdz_txt_color
    __phdz_txt_color['black']=$(tput setaf 0)
    __phdz_txt_color['red']=$(tput setaf 1)
    __phdz_txt_color['green']=$(tput setaf 2)
    __phdz_txt_color['yellow']=$(tput setaf 3)
    __phdz_txt_color['blue']=$(tput setaf 4)
    __phdz_txt_color['magenta']=$(tput setaf 5)
    __phdz_txt_color['cyan']=$(tput setaf 6)
    __phdz_txt_color['white']=$(tput setaf 7)

    local _bold=${__phdz_txt_attr['bold']}
    __phdz_txt_color['BLACK']=${bold}${__phdz_txt_color['black']}
    __phdz_txt_color['RED']=${bold}${__phdz_txt_color['red']}
    __phdz_txt_color['GREEN']=${bold}${__phdz_txt_color['green']}
    __phdz_txt_color['YELLOW']=${bold}${__phdz_txt_color['yellow']}
    __phdz_txt_color['BLUE']=${bold}${__phdz_txt_color['blue']}
    __phdz_txt_color['MAGENTA']=${bold}${__phdz_txt_color['magenta']}
    __phdz_txt_color['CYAN']=${bold}${__phdz_txt_color['cyan']}
    __phdz_txt_color['WHITE']=${bold}${__phdz_txt_color['white']}
  fi

  # Make read-only
  declare -gr __phdz_txt_attr __phdz_txt_color
}

function __phdz_logf_error()
{
  local _msg=$1; shift
  local _RED=${__phdz_txt_color['RED']}
  local _nc=${__phdz_txt_attr['CLEAR']}
  >&2 printf "${_RED}ERROR - ${_nc}${_msg}\n" "$@"
}


#----
# Smarter "cd"
#----
function __phdz_dirring_msg()
{
  local _header=$1
  local _target=$2
  local _magenta=${__phdz_txt_color['magenta']}
  local _cyan=${__phdz_txt_color['cyan']}
  local _nc=${__phdz_txt_attr['CLEAR']}
  >&2 printf "${_magenta}%s:${_nc} ${_cyan}%s${_nc}\n" "$_header" "$_target"
}

function __phdz_dirring_get_dir()
{
  local _user_index=$1
  local _real_index=$2

  local _target=${dirstack[$_real_index]}
  if [[ -d "$_target" ]]; then
    echo "$_target"
  elif [[ -z "$_target" ]]; then
    __phdz_logf_error "Index of '%s' is invalid." "$_user_index"
    echo ""
  else
    __phdz_logf_error "Directory does not exist: %s" "$_target"
    echo ""
  fi
}

function __phdz_dirring()
{
  local -i _dirstack_size=${#dirstack[@]}
  if [[ ! ${1:=0} =~ ^[+-]{0,1}[0-9]+$ ]]; then
    __phdz_logf_error "Dirstack index of '%s' is invalid.  The index must be between '%d' and '%d'." \
      "$1" $_dirstack_size $((-_dirstack_size))
    return 1
  fi

  local -i _user_index=${1:=0}
  if [[ $_user_index -ne 0 ]] && [[ $_dirstack_size -eq 0 ]]
  then
    __phdz_logf_error "Dirstack is empty."
    return 1
  fi

  if [[ $_user_index -lt $((-_dirstack_size)) ]] \
    || [[ $_user_index -gt $_dirstack_size ]]
  then
    __phdz_logf_error "Dirstack index of '%d' is out of range.  The index must be between '%d' and '%d'." \
      $_user_index $_dirstack_size $((-_dirstack_size))
    return 1
  fi

  local _real_index  # Must be string!
  local _direction
  if [[ $_user_index -eq 0 ]]; then
    builtin dirs -v
    return 0
  elif [[ $_user_index -gt 0 ]]; then
    _real_index="+$_user_index"
    _direction='backward'
  elif [[ $_user_index -lt 0 ]]; then
    _real_index="-$(( _user_index + _dirstack_size + 1 ))"
    _direction='forward'
  fi

  local _target
  _target=$(__phdz_dirring_get_dir "$_user_index" "$_real_index")
  [[ -n "$_target" ]] \
    || return 1

  __phdz_dirring_msg "Rotating $_direction to" "$_target"
  # builtin pushd "${_real_index}" > /dev/null \
  #   || return 1
}


__phdz_load_color_variables

# cd related
# alias cd='__phdz_dirring_cd'
# alias ..='__phdz_dirring_cd ..'
# alias -- -='__phdz_dirring_cd -'
alias d='__phdz_dirring'
# alias r='__phdz_dirring_reverse'
# alias x='__phdz_dirring_remove'




# function __phdz_dirring_cd ()
# {
#   local new_pwd="$*"
#
#   if [ -z "$new_pwd" ]; then
#     new_pwd="$HOME"
#   fi
#
#   builtin pushd "$new_pwd" > /dev/null 2>&1
#   if [ $? -ne 0 ]; then
#     printf "${cl_RED}ERROR - Failed to change directory:${cl_NC} $(__phdz_dirring_escape ${new_pwd})\a\n"
#     return 1
#   fi
#
#   printf "${cl_magenta}Current working directory:${cl_NC} $(__phdz_dirring_escape ${PWD})${cl_NC}\n"
#   __phdz_set_term_title $PWD
# }

# function __phdz_dirring_remove ()
# {
#   local index=$1
#   if [ -z "$index" ]; then
#     index="1"
#   fi
#
#   local l_target=$(__phdz_dirring_escape ${DIRSTACK[$index]})
#   printf "${cl_magenta}Removing from DIRSTACK:${cl_NC} ${cl_cyan}${l_target}${cl_NC}\n"
#   builtin popd -n +$index > /dev/null
#   __phdz_dirring_list
# }

# function __phdz_dirring_reverse ()
# {
#   local index=$1
#   if [ -z "$index" ]; then
#     index="1"
#   fi
#
#   local l_target=$(__phdz_dirring_escape ${DIRSTACK[$index]})
#   printf "${cl_magenta}Reversing to:${cl_NC} ${cl_cyan}${l_target}${cl_NC}\n"
#   for (( c=1; c < $index; c++ )); do
#     builtin popd -n > /dev/null
#   done
#   builtin popd > /dev/null
#   __phdz_dirring_list
# }


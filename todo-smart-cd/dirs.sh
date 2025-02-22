DIRSTACKSIZE=20
setopt autopushd pushdsilent pushdtohome # pushdminus 



function __pfh_load_color_variables()
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

  if [[ -z ${__pfh_txt_attr+x} ]]; then
    declare -gA __pfh_txt_attr
    __pfh_txt_attr['bold']=$(tput bold)
    __pfh_txt_attr['underline']=$(tput smul)
    __pfh_txt_attr['dim']=$(tput dim)
    __pfh_txt_attr['rev']=$(tput rev)
    __pfh_txt_attr['CLEAR']=$(tput sgr0)
  fi

  if [[ -z ${__pfh_txt_color+x} ]]; then
    declare -gA __pfh_txt_color
    __pfh_txt_color['black']=$(tput setaf 0)
    __pfh_txt_color['red']=$(tput setaf 1)
    __pfh_txt_color['green']=$(tput setaf 2)
    __pfh_txt_color['yellow']=$(tput setaf 3)
    __pfh_txt_color['blue']=$(tput setaf 4)
    __pfh_txt_color['magenta']=$(tput setaf 5)
    __pfh_txt_color['cyan']=$(tput setaf 6)
    __pfh_txt_color['white']=$(tput setaf 7)

    local _bold=${__pfh_txt_attr['bold']}
    __pfh_txt_color['BLACK']=${bold}${__pfh_txt_color['black']}
    __pfh_txt_color['RED']=${bold}${__pfh_txt_color['red']}
    __pfh_txt_color['GREEN']=${bold}${__pfh_txt_color['green']}
    __pfh_txt_color['YELLOW']=${bold}${__pfh_txt_color['yellow']}
    __pfh_txt_color['BLUE']=${bold}${__pfh_txt_color['blue']}
    __pfh_txt_color['MAGENTA']=${bold}${__pfh_txt_color['magenta']}
    __pfh_txt_color['CYAN']=${bold}${__pfh_txt_color['cyan']}
    __pfh_txt_color['WHITE']=${bold}${__pfh_txt_color['white']}
  fi

  # Make read-only
  declare -gr __pfh_txt_attr __pfh_txt_color
}



#----
# Smarter "cd"
#----
function __pfh_dirs_msg()
{
  local _header=$1
  local _target=$2
  local _magenta=${__pfh_txt_color['magenta']}
  local _cyan=${__pfh_txt_color['cyan']}
  local _nc=${__pfh_txt_attr['CLEAR']}
  >&2 printf "${_magenta}%s:${_nc} ${_cyan}%s${_nc}\n" "$_header" "$_target"
}

function __pfh_dirs_get_dir()
{
  local _user_index=$1
  local _real_index=$2

  local _target=${dirstack[$_real_index]}
  if [[ -d "$_target" ]]; then
    echo "$_target"
  elif [[ -z "$_target" ]]; then
    __pfh_logf_error "Index of '%s' is invalid." "$_user_index"
    echo ""
  else
    __pfh_logf_error "Directory does not exist: %s" "$_target"
    echo ""
  fi
}


function __pfh_logf_error()
{
  local _msg=$1; shift
  local _RED=${__pfh_txt_color['RED']}
  local _nc=${__pfh_txt_attr['CLEAR']}
  >&2 printf "${_RED}ERROR - ${_nc}${_msg}\n" "$@"
}


function __pfh_dirs_rotate_forward()
{
  local -i _dirstack_size=${#dirstack[@]}
  if [[ ! ${1:=0} =~ ^[+-]{0,1}[0-9]+$ ]]; then
    __pfh_logf_error "Dirstack index of '%s' is invalid.  The index must be between '%d' and '%d'." \
      "$1" $_dirstack_size $((-_dirstack_size))
    return 1
  fi

  local -i _user_index=${1:=0}
  if [[ $_user_index -lt $((-_dirstack_size)) ]] \
    || [[ $_user_index -gt $_dirstack_size ]]
  then
    __pfh_logf_error "Dirstack index of '%d' is out of range.  The index must be between '%d' and '%d'." \
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
  _target=$(__pfh_dirs_get_dir "$_user_index" "$_real_index")
  [[ -n "$_target" ]] \
    || return 1

  __pfh_dirs_msg "Rotating $_direction to" "$_target"
  # builtin pushd "${_real_index}" > /dev/null \
  #   || return 1
}


__pfh_load_color_variables

# cd related
# alias cd='__pfh_dirs_cd'
# alias ..='__pfh_dirs_cd ..'
# alias -- -='__pfh_dirs_cd -'
alias d='__pfh_dirs_rotate_forward'
# alias r='__pfh_dirs_reverse'
# alias x='__pfh_dirs_remove'




# function __pfh_dirs_cd ()
# {
#   local new_pwd="$*"
#
#   if [ -z "$new_pwd" ]; then
#     new_pwd="$HOME"
#   fi
#
#   builtin pushd "$new_pwd" > /dev/null 2>&1
#   if [ $? -ne 0 ]; then
#     printf "${cl_RED}ERROR - Failed to change directory:${cl_NC} $(__pfh_dirs_escape ${new_pwd})\a\n"
#     return 1
#   fi
#
#   printf "${cl_magenta}Current working directory:${cl_NC} $(__pfh_dirs_escape ${PWD})${cl_NC}\n"
#   __pfh_set_term_title $PWD
# }

# function __pfh_dirs_remove ()
# {
#   local index=$1
#   if [ -z "$index" ]; then
#     index="1"
#   fi
#
#   local l_target=$(__pfh_dirs_escape ${DIRSTACK[$index]})
#   printf "${cl_magenta}Removing from DIRSTACK:${cl_NC} ${cl_cyan}${l_target}${cl_NC}\n"
#   builtin popd -n +$index > /dev/null
#   __pfh_dirs_list
# }

# function __pfh_dirs_reverse ()
# {
#   local index=$1
#   if [ -z "$index" ]; then
#     index="1"
#   fi
#
#   local l_target=$(__pfh_dirs_escape ${DIRSTACK[$index]})
#   printf "${cl_magenta}Reversing to:${cl_NC} ${cl_cyan}${l_target}${cl_NC}\n"
#   for (( c=1; c < $index; c++ )); do
#     builtin popd -n > /dev/null
#   done
#   builtin popd > /dev/null
#   __pfh_dirs_list
# }


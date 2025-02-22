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
function __pfh_dirs_list()
{
  builtin dirs -v
}

function __pfh_dirs_msg()
{
  local _header=$1
  local _target=${dirstack[$2]}

  local _magenta=${__pfh_txt_color['magenta']}
  local _cyan=${__pfh_txt_color['cyan']}
  local _nc=${__pfh_txt_attr['CLEAR']}

  >&2 printf "${_magenta}%s:${_nc} ${_cyan}%s${_nc}\n" "$_header" "$_target"
}

function __pfh_log_error()
{
  local _msg=$*
  local _RED=${__pfh_txt_color['RED']}
  local _nc=${__pfh_txt_attr['CLEAR']}
  >&2 printf "${_RED}ERROR - ${_nc}%s\n" "$_msg"
}

function __pfh_dirs_validate_dir()
{
  local _target=$1
  if [[ ! -d "$_target" ]]; then
    __pfh_log_error "Directory does not exist: $_target"
    return 1
  fi
}

function __pfh_dirs_rotate_back()
{
  local _index=$1
  if [[ -z "$_index" ]]; then
    _index=1
  fi

  local _target=${dirstack[$_index]}
  if [[ ! -d "$_target" ]]; then
    __pfh_log_error "Directory does not exist: $_target"
    return 1
  fi

  __pfh_dirs_msg "Rotating back to" "$_index"
  builtin pushd +"${_index}" > /dev/null || return 1
}

function __pfh_dirs_msg_new()
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
    __pfh_log_error "Index of '$_user_index' is invalid."
    echo ""
  else
    __pfh_log_error "Directory does not exist: $_target"
    echo ""
  fi
}

function __pfh_dirs_rotate_forward()
{
  local -i _user_index=${1:=1}
  _user_index=${1:=1}

  if [[ $_user_index < 1 ]] || [[ $_user_index > ${#dirstack[@]} ]]; then
    echo  BANG
  fi


  local _reverse_index=$(( _user_index - 1 ))
  local _real_index=$(( ${#dirstack[@]} - _reverse_index ))

  local _target
  _target=$(__pfh_dirs_get_dir "$_user_index" "$_real_index")
  [[ -n "$_target" ]] \
    || return 1

  __pfh_dirs_msg_new "Rotating forward to" "$_target"
  # builtin pushd -${_index} > /dev/null \
  #   || return 1
}


__pfh_load_color_variables

# cd related
# alias cd='__pfh_dirs_cd'
# alias ..='__pfh_dirs_cd ..'
# alias -- -='__pfh_dirs_cd -'
alias d='__pfh_dirs_list'
alias b='__pfh_dirs_rotate_back'
alias f='__pfh_dirs_rotate_forward'
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


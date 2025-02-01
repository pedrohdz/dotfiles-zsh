setopt autopushd pushdsilent pushdtohome &> /dev/null

export DIRSTACKSIZE=50

if [[ -o interactive ]] && (( ${terminfo[colors]:-0} >= 8 )); then
  autoload -Uz colors
  colors
else
  typeset -g reset_color=
  typeset -g bold=
  typeset -g fg=()
  typeset -g bg=()
fi


#------------------------------------------------------------------------------
# Logging functions
#------------------------------------------------------------------------------
function __phdz_logf_error()
{
  local _msg=$1; shift
  >&2 printf "${fg_bold[red]}ERROR - ${reset_color}${_msg}\n" "$@"
}

function __phdz_dirring_msg()
{
  local _header=$1
  local _target=$2
  >&2 printf "${fg[magenta]}%s:${reset_color} ${fg[cyan]}%s${reset_color}\n" "$_header" "$_target"
}


#------------------------------------------------------------------------------
# Dirring functions
#------------------------------------------------------------------------------
function __phdz_dirring()
{
  local -i _dirstack_size
  _dirstack_size=${#dirstack[@]}
  if [[ ! ${1:-0} =~ ^[+-]{0,1}[0-9]+$ ]]; then
    __phdz_logf_error "Dirstack index of '%s' is invalid.  The index must be between '%d' and '%d'." \
      "$1" $_dirstack_size $((-_dirstack_size))
    return 1
  fi

  local -i _user_index=${1:-0}
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

  local _cd_parameter=""  # Must be string!
  if [[ $_user_index -eq 0 ]]; then
    __phdz_dirring_list
    return 0
  elif [[ $_user_index -gt 0 ]]; then
    _cd_parameter="+$_user_index"
  elif [[ $_user_index -lt 0 ]]; then
    # The funny math below allows for a '-0' string, which is valid for pushd.
    _cd_parameter="-$(( -_user_index - 1 ))"
  fi

  __phdz_dirring_cd "${_cd_parameter}" \
    || return 1
}

function __phdz_dirring_cd ()
{
  local _new_pwd=${*:-$HOME}

  local _msg
  if [[ $_new_pwd =~ ^\\+.+ ]]; then
    _msg='Rotated forward to'
  elif [[ $_new_pwd =~ ^-.+ ]]; then
    _msg='Rotated backward to'
  else
    _msg='Current working directory'
  fi

  if ! builtin pushd "$_new_pwd" > /dev/null; then
    __phdz_logf_error "Failed to change directory: %s" "$_new_pwd"
    return 1
  fi

  __phdz_dirring_msg "$_msg" "$PWD"
  # FIXME - __phdz_set_term_title $PWD
}

function __phdz_dirring_list
{
  # Get the 'dirs -p' output into an array, one line per entry
  local -a _dir_lines=("${(@f)$(dirs -p)}")
  local _total_lines=${#_dir_lines[@]}

  # Determine the maximum path length for formatting
  local -i _max_path_length=0
  local _line
  for _line in "${_dir_lines[@]}"; do
    (( ${#_line} > _max_path_length )) \
      && _max_path_length=${#_line}
  done

  # Print the header line
  printf 'IdxF  IdxB  %s\n' "Path"
  local _path_dash=${(l:${_max_path_length}::-:)""}
  printf '----  ----  %s\n' "$_path_dash"

  # Print each entry line
  local -i _index
  printf "            %s\n" "${_dir_lines[1]}"  # (CWD) Print first line separately
  for (( _index = 2; _index <= _total_lines; _index++ )); do
    printf "%4d  %4d  %s\n" \
      "$((_index - 1))" \
      "$((_index - 1 - _total_lines))" \
      "${_dir_lines[$_index]}"
  done
}


#------------------------------------------------------------------------------
# Public interface
#------------------------------------------------------------------------------
function d () {
  __phdz_dirring "$@"
}


#------------------------------------------------------------------------------
# TODO - Add these back later
#------------------------------------------------------------------------------

# alias r='__phdz_dirring_reverse'
# alias x='__phdz_dirring_remove'

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


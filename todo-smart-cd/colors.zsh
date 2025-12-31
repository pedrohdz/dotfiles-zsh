() {
  # TODO - Fix this
  if ! command -v tput &> /dev/null \
      || [[ $(tput -T"$TERM" colors) -lt 8 ]]; then

    declare -gA __phdz_txt_attr
    __phdz_txt_attr['bold']=''
    __phdz_txt_attr['underline']=''
    __phdz_txt_attr['dim']=''
    __phdz_txt_attr['rev']=''
    __phdz_txt_attr['CLEAR']=''

    declare -gA __phdz_txt_color
    __phdz_txt_color['black']=''
    __phdz_txt_color['red']=''
    __phdz_txt_color['green']=''
    __phdz_txt_color['yellow']=''
    __phdz_txt_color['blue']=''
    __phdz_txt_color['magenta']=''
    __phdz_txt_color['cyan']=''
    __phdz_txt_color['white']=''
    __phdz_txt_color['BLACK']=''
    __phdz_txt_color['RED']=''
    __phdz_txt_color['GREEN']=''
    __phdz_txt_color['YELLOW']=''
    __phdz_txt_color['BLUE']=''
    __phdz_txt_color['MAGENTA']=''
    __phdz_txt_color['CYAN']=''
    __phdz_txt_color['WHITE']=''
    return
  fi

  # Read up on:
  #   - http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
  #   - http://www.termsys.demon.co.uk/vtansi.htm#colors  (Historical)
  if [[ ${#__phdz_txt_attr[@]} -eq 0 ]]; then
    declare -gA __phdz_txt_attr
    __phdz_txt_attr['bold']=$(tput bold)
    __phdz_txt_attr['underline']=$(tput smul)
    __phdz_txt_attr['dim']=$(tput dim)
    __phdz_txt_attr['rev']=$(tput rev)
    __phdz_txt_attr['CLEAR']=$(tput sgr0)
  fi

  if [[ ${#__phdz_txt_color[@]} -eq 0 ]]; then
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

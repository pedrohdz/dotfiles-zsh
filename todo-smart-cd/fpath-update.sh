
for x in $fpath; do
  echo HERE: $x
done

function _rename()
{
  local _local_prefix
  if which port > /dev/null; then
    _local_prefix=$(dirname "$(dirname "$(which port)")")
  else
    _local_prefix='/usr/local'
  fi

  local _fdirs
  _paths=( \
    '/Users/pedro.hernandez/.homesick/repos/homeshick/completions' \
    '/Users/pedro.hernandez/.local/share/zsh/site-functions' \
    '/opt/devenv/share/zsh/site-functions' \
    '/usr/local/share/zsh/site-functions' \
    '/usr/share/zsh/site-functions' \
    '/usr/share/zsh/5.9/functions' \
    '/Users/pedro.hernandez/.antigen/bundles/romkatv/powerlevel10k' \
    '/Users/pedro.hernandez/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/vi-mode' \
    '/Users/pedro.hernandez/.antigen/bundles/zsh-users/zsh-autosuggestions' \
    '/Users/pedro.hernandez/.antigen/bundles/mfaerevaag/wd' \
  )

  for _dir in "${_paths[@]}"; do
    echo "Processing: $_dir"

    if (($fpath[(Ie)$_dir])); then
      echo value is amongst the values of the array
    fi
    if [[ -f $_dir ]]; then
      # source "$_file"
    fi
  done

}


_rename


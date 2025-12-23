# TODO - merge with ./az_completion.sh
l_target=vagrant

if ! which $l_target > /dev/null; then
  return 0
fi

l_base_dir=$(builtin cd "$(dirname ${BASH_SOURCE[0]})/.." ; pwd)
l_completion_dir="$l_base_dir/completion-available"
l_source_path="$l_completion_dir/$l_target.completion"

if [ -f "$l_source_path" ]; then
  source "$l_source_path"
fi

unset l_base_dir l_completion_dir l_source_path l_target

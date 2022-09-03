# shellcheck shell=bash

function py-activate()
{
  # Is there a local virtualenv
  local _activate="$PWD/.venv/bin/activate"
  if [ ! -e "$_activate" ]; then
    echo "ERROR - Could not find '$_activate'"
    return 1
  fi

  echo "Activating: $_activate"
  # shellcheck disable=SC1090
  source "$_activate"
  # shellcheck disable=SC2181  # source call must be checked with $?
  if [ $? -ne 0 ]; then
    echo "ERROR - Failed to exectute '$_activate'"
    return 1
  fi
}

# vim: filetype=bash

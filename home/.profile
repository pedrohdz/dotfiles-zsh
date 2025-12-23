# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022

export LC_ALL=en_US.UTF-8


# FIXME - Android SDK for OS X (Pathes have changed.
if [ -d "$HOME/dev/tool/adt-sdk" ] ; then
  export ANDROID_HOME=$HOME/dev/tool/adt-sdk

  if [ -d "$ANDROID_HOME/platform-tools" ] ; then
    export PATH=$ANDROID_HOME/platform-tools:$PATH
  fi

  if [ -d "$ANDROID_HOME/tools" ] ; then
    export PATH=$ANDROID_HOME/tools:$PATH
  fi
fi

# Java on OS X
_java_version='17'
if /usr/libexec/java_home -v "$_java_version" > /dev/null 2>&1; then
  export JAVA_HOME=$(/usr/libexec/java_home -v "$_java_version")

  if [ -d "$JAVA_HOME/bin" ]; then
    export PATH=$JAVA_HOME/bin:$PATH
  fi
fi
unset _java_version

# local user bin
export USER_LOCAL="$HOME/.local"
if [ -d "$USER_LOCAL" ]; then
    if [ -d "$USER_LOCAL/bin" ]; then
        export PATH="$USER_LOCAL/bin:$PATH"
    fi
    if [ -d "$USER_LOCAL/share/man" ]; then
        export MANPATH="$USER_LOCAL/share/man:$MANPATH"
    fi
fi

# PATH variable for use with MacPorts.
if [ -f "/opt/local/bin/port" ] ; then
    export PATH=/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH
    export MANPATH=/opt/local/share/man:$MANPATH
fi

# devenv
export DEVENV_ROOT='/opt/devenv'
if [ -d "$DEVENV_ROOT" ]; then
    if [ -d "$DEVENV_ROOT/bin" ]; then
        export PATH="$DEVENV_ROOT/bin:$PATH"
    fi
    if [ -d "$DEVENV_ROOT/share/man" ]; then
        export MANPATH="$DEVENV_ROOT/share/man:$MANPATH"
    fi
fi

## Ruby Gem bins.
#if which gem > /dev/null; then
#  path_prefix=$(
#    set -o errexit
#    IFS=':'
#    for current in $(gem environment gempath); do
#      gem_bin_dir="$current/bin"
#      if [ -d "$gem_bin_dir" ]; then
#        gem_bin_path="${gem_bin_path:+$gem_bin_path:}$gem_bin_dir"
#      fi
#    done
#    echo "$gem_bin_path"
#  )
#  export PATH="${path_prefix:+$path_prefix:}$PATH"
#  unset path_prefix
#fi


#------------------------------------------------------------------------------
# XDG_CONFIG_HOME
#------------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"


#------------------------------------------------------------------------------
# SSH Agent
#------------------------------------------------------------------------------
ssh_agent_start() {
  # Thank you: https://stackoverflow.com/a/18915067
  printf "SSH agent → "

  if [ -n "$SSH_CONNECTION" ] \
        && echo "$SSH_AUTH_SOCK" | grep -q "ssh-.*/agent\."
  then
    printf "forwarded\n"
    return
  fi

  _ssh_agent_env="$HOME/.ssh/agent-environment"
  if [ -f "$_ssh_agent_env" ]; then
    . "$_ssh_agent_env"
    if ps -o 'command=' -p "$SSH_AGENT_PID" | grep 'ssh-agent' > /dev/null; then
      printf "running\n"
      unset _ssh_agent_env
      return
    fi
  fi

  _ssh_agent_cmd=$(which ssh-agent)
  printf "starting (%s) → " "$_ssh_agent_cmd"
  "$_ssh_agent_cmd" -t 5h | sed 's/^echo/# echo/' > "$_ssh_agent_env"
  chmod 0600 "$_ssh_agent_env"
  . "$_ssh_agent_env"
  printf "started\n"
  unset _ssh_agent_cmd _ssh_agent_env
}

ssh_agent_start


#------------------------------------------------------------------------------
# BS guard
#------------------------------------------------------------------------------
# Mac Ports typically likes to add its junk to the end of this file, which is
# bad news.  This file (.profile) is shared with other non-OSX systems.  So
# stop processing at this point!
return 0

#-BS guard---------------------------------------------------------------------


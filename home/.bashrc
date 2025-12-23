# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


#------------------------------------------------------------------------------
# Includes & Completions
#------------------------------------------------------------------------------
if [ -d "/opt/local/etc/macports" ]; then
    local_prefix="/opt/local"
else
    local_prefix="/usr/local"
fi

if which brew > /dev/null; then
  l_brew_prefix=$(brew --prefix)
else
  l_brew_prefix='/DOES/NOT/EXIST'
fi

# Old completion lines
l_includes=( \
    # ---- Regular includes ----
    ${local_prefix}/etc/profile.d/*.sh \
    ${HOME}/.local/etc/shell-common/config.d/*.sh \
    ${HOME}/.bashrc_pfh_func \
    ${HOME}/.homesick/repos/homeshick/homeshick.sh \
    ${local_prefix}/share/git/contrib/completion/git-prompt.sh \
    ${HOME}/.local/etc/bash/bashrc.d/*.sh \
    # ---- Bash Completion ----
    ${local_prefix}/etc/bash_completion.d/* \
    ${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash \
    /etc/profile.d/avinode-gradle-completion.sh \
    # TODO - Remove? ${HOME}/.local/etc/bash/completion.d/*.sh \
    # ---- Local config last ----
    ${HOME}/.bashrc_local \
    # ---- Brew ----
    # TODO - Remove? ${l_brew_prefix}/etc/bash_completion.d/az \
    ${l_brew_prefix}/etc/bash_completion.d/brew \
    /opt/devenv/etc/bash_completion.d/*.sh \
)

for l_file in ${l_includes[@]}; do
    if [ -f $l_file ]; then
        #echo "Processing: $l_file"
        source $l_file
    fi
done
unset l_file l_includes l_brew_prefix


#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
# Turn on ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# HISTSIZE and HISTFILESIZE in lines
export HISTSIZE=5000
export HISTFILESIZE=2500


###############################################################################
# Requires ~/.bashrc_pfh_func
# TODO - Reorganize
###############################################################################
if [ ${__PFH_BASHRC_LOADED:-FALSE} != 'TRUE' ] ; then
    echo "WARNING: Stopped processing .bashrc.  Failed to load .bashrc_pfh_func."
    return
fi


#------------------------------------------------------------------------------
# Shell variables
#------------------------------------------------------------------------------
term_title_base="${USER}@${HOSTNAME}"
term_title_on="TRUE"
__pfh_load_color_variables


#------------------------------------------------------------------------------
# Aliases
#------------------------------------------------------------------------------
# PFH functions
alias search='__pfh_searchfiles'
alias myconn='__pfh_mysql_client'
alias vim=__pfh_vim_set_term_title
alias fbs=__pfh_find_broken_symlinks

# cd related
alias cd='__pfh_dirs_cd'
alias ..='__pfh_dirs_cd ..'
alias -- -='__pfh_dirs_cd -'
alias d='__pfh_dirs_list'
alias b='__pfh_dirs_rotate_back'
alias f='__pfh_dirs_rotate_forward'
alias r='__pfh_dirs_reverse'
alias x='__pfh_dirs_remove'


#------------------------------------------------------------------------------
# Cygwin
#------------------------------------------------------------------------------
if [ "$OSTYPE" = "cygwin" ]; then
    #----
    # Aliases
    #----
    builtin alias cpwd='/usr/bin/cygpath.exe -wla .'

    __pfh_cygwin_command_alias "plain" "csvcutil" "${ProgramW6432}\\Microsoft SDKs\\Windows\\v6.0A\\Bin\\x64\\SvcUtil.exe"

    if [ -n "$VS90COMNTOOLS" ]; then
        vs_devenv_path=$(/usr/bin/cygpath.exe -wla "${VS90COMNTOOLS}\\..\\IDE\\devenv.exe")
        __pfh_cygwin_command_alias "plain" "cdevenv" "$vs_devenv_path"
    fi
fi


#------------------------------------------------------------------------------
# Final Commands
#------------------------------------------------------------------------------
__pfh_set_term_title "$PWD"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend

#export PS1="${debian_chroot:+($debian_chroot)}\\[${cl_yellow}\\]\\u@\\h\\[${cl_NC}\\]:\\[${cl_magenta}\\]\\W\\[${cl_NC}\\]\\$ "
export VIRTUAL_ENV_DISABLE_PROMPT=true
export PROMPT_COMMAND=__pfh_prompt_command


#------------------------------------------------------------------------------
# Other
#------------------------------------------------------------------------------
if [ -x '/Applications/VMware Fusion.app/Contents/Library/vmrun' ]; then
  alias vmrun='/Applications/VMware\ Fusion.app/Contents/Library/vmrun'
fi


# BS blocker.  Why do installers think it is OK to modify peoples' RC files?
return 0

#complete -C /opt/local/bin/terraform0.12 terraform0.12
#complete -C /Users/pedher/dev/src-avi/ansible-playbooks/build/home/bin/terraform0.12.30 terraform0.12.30
#complete -C /opt/devenv/bin/terraform terraform

if ! command -v which fzf &> /dev/null; then
  return 0
fi

#------------------------------------------------------------------------------
# Source shell configuration
#------------------------------------------------------------------------------
source <(command fzf --zsh)



#------------------------------------------------------------------------------
# Configure completions (completion.zsh)
#------------------------------------------------------------------------------
# export FZF_DEFAULT_OPTS=
export FZF_TMUX=0  # I like the window to be close to the current command
export FZF_COMPLETION_OPTS='--reverse --info=inline'

if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='command fd --hidden --follow --exclude .git'

  _fzf_compgen_path() {
    command fd --hidden --follow --exclude '.git' . "$1"
  }

  _fzf_compgen_dir() {
    command fd --type d --hidden --follow --exclude '.git' . "$1"
  }
fi


#------------------------------------------------------------------------------
# Configure shell key bindings (key-bindings.zsh)
#------------------------------------------------------------------------------
export FZF_CTRL_R_OPTS=$FZF_COMPLETION_OPTS

if command -v tree &> /dev/null; then
  export FZF_ALT_C_OPTS="
    $FZF_COMPLETION_OPTS
    --walker-skip .git,node_modules,target
    --preview 'tree -C {}'"
fi

if command -v bat &> /dev/null; then
export FZF_CTRL_T_OPTS="
    $FZF_COMPLETION_OPTS
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {}'
    --footer '${fg[blue]}≪ ^-/•change-preview-window ≫${reset_color}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi


#------------------------------------------------------------------------------
# Fancy helpers
#------------------------------------------------------------------------------
nvim-picker() (
  local _reload='reload:rg --column --color=always --smart-case {q} || :'
  local _opener='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'

  command fzf --disabled --ansi --multi \
    --reverse --info=inline \
    --bind "start:$_reload" --bind "change:$_reload" \
    --bind "enter:become:$_opener" \
    --bind "ctrl-o:execute:$_opener" \
    --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
    --footer "${fg[blue]}≪ alt-a•select-all alt-d•deselect-all ^-/•toggle-preview ≫${reset_color}" \
    --delimiter : \
    --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
    --preview-window '~4,+{2}+4/3,<80(up)' \
    --query "$*"
)

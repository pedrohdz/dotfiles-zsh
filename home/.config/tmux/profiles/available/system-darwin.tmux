
# Configure status bar
#set-option -g status-bg blue
#set-option -g status-fg white

bind-key -T copy-mode-vi y send-keys -X copy-pipe "pbcopy" \; \
        display-message "Copied to clipboard." \; \
        send -X clear-selection

#bind-key  -T copy-mode-vi Enter send-keys -X copy-pipe "pbcopy" \; \
#        display-message "Copied to clipboard." \; \
#        send -X cancel

#------------------------------------------------------------------------------
# Mouse support
#------------------------------------------------------------------------------
set -g mouse on

bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe pbcopy
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe pbcopy

#set -g default-terminal "screen-256color"


# vim: filetype=tmux

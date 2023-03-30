source $BYOBU_PREFIX/share/byobu/profiles/tmux

set -sg escape-time 0
set -g base-index 1
set -g status-interval 1
set -g default-terminal "screen-256color"
set -g history-limit 10000

unbind C-b
set -g prefix C-a
bind-key C-a send-prefix
bind-key C-a last-window
bind-key | split-window -h
bind-key - split-window -v
bind-key _ split-window -v
bind-key k kill-pane

set-window-option -g window-status-style fg=white,bg=colour240
set-window-option -g window-status-current-style fg=black,bg=colour220,bold
set -g status-left-length 28
set -g status-left "#[fg=cyan,bg=black]:#S >> "
set -g status-right-length 16
set -g status-right '#[fg=colour220,bg=black]%Y-%m-%d %H:%M'

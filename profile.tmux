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

set-window-option -g window-status-style fg=white,bg=black
set-window-option -g window-status-current-style fg=black,bg=green,bold

set -g status-left-length 28
set -g status-left "#[fg=white]@#h#[fg=green]:#S#[fg=white] |"
set -g status-right-length 16
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M'
# ~/.bashrc: executed by bash(1) for non-login shells.
# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
#PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'

# umask 022
# You may uncomment the following lines if you want `ls' to be colorized:

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# alias ll='ls $LS_OPTIONS -lF'
# alias la='ls $LS_OPTIONS -lAF'

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
# alias ll='ls $LS_OPTIONS -CFlah'
alias nt='/usr/local/bin/nexttrace'
alias z='zellij'
alias ls="eza --time-style=long-iso --icons --group --binary -lg"
alias tree="eza --tree --icons"
#!/usr/bin/env bash
# If any attached client is via mosh, switch prefix to C-b and hide CPU/RAM.
# To restore: tmux source ~/.tmux.conf

while IFS= read -r pid; do
    p=$pid
    while [ "${p:-0}" -gt 1 ] 2>/dev/null; do
        if [ "$(ps -o comm= -p "$p" 2>/dev/null)" = "mosh-server" ]; then
            tmux set -g prefix C-b
            tmux unbind C-a
            tmux bind C-b send-prefix
            # Hide Dracula widgets but keep nested-session OFF indicator (see ~/.tmux.conf)
            tmux set -g status-right "#[fg=#f8f8f2,bg=#ff5555,bold]#([ \$(tmux show-option -qv key-table) = 'off' ] && echo ' OFF ')#[default]"
            exit 0
        fi
        p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
    done
done < <(tmux list-clients -F '#{client_pid}')

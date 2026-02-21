#!/usr/bin/env bash
# Adapt tmux for remote connections:
#   mosh  → switch prefix to C-b (C-a conflicts with readline)
#   SSH   → move status bar to bottom

rs_is_mosh=false

while IFS= read -r pid; do
    rs_p=$pid
    while [ "${rs_p:-0}" -gt 1 ] 2>/dev/null; do
        if [ "$(ps -o comm= -p "$rs_p" 2>/dev/null)" = "mosh-server" ]; then
            rs_is_mosh=true
            break 2
        fi
        rs_p=$(ps -o ppid= -p "$rs_p" 2>/dev/null | tr -d ' ')
    done
done < <(tmux list-clients -F '#{client_pid}')

if $rs_is_mosh; then
    tmux set -g prefix C-b
    tmux unbind C-a
    tmux bind C-b send-prefix
fi

if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]; then
    tmux set -g status-position bottom
fi

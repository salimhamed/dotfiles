# --- Lazygit ---
alias lazyyadm='lazygit --use-config-file "${HOME}/.config/yadm/lazygit.yml,${HOME}/.config/lazygit/config.yml" --work-tree "${HOME}" --git-dir "${HOME}/.local/share/yadm/repo.git"'
alias ly='lazyyadm'
alias lg='lazygit'

# --- Editor ---
alias v='nvim'

# --- Standard command defaults ---
alias mkdir='mkdir -pv'
alias less='less -FSRXc'

# --- Modern alternatives ---
alias ls='eza'
alias ll='eza -la --header --git --icons --changed --time-style=iso'

# Interactive terminal aliases
if [[ -t 1 ]]; then
    alias cp='cp -iv'
    alias mv='mv -iv'
    if command -v batcat &>/dev/null; then
        alias cat='batcat'
    elif command -v bat &>/dev/null; then
        alias cat='bat'
    fi
    alias cd='z'
fi

# --- Git ---
alias git-count='git ls-files | xargs wc -l'

# --- Helper functions ---

listening_on_port() {
    sudo lsof -n -i:"${1}" | grep LISTEN
}

listening_on_ports() {
    sudo lsof | grep LISTEN
}

ssm() {
    aws ssm start-session --target "${1}"
}

count_lines_of_code() {
    git clone --depth 1 "$1" /tmp/temp-linecount-repo &&
        printf "('/tmp/temp-linecount-repo' will be deleted automatically)\n\n\n" &&
        cloc /tmp/temp-linecount-repo &&
        rm -rf /tmp/temp-linecount-repo
}

# --- Tmux ---

tclean() {
    local current=$(tmux display-message -p '#{client_name}')
    tmux list-clients -F '#{client_name}' | while read -r client; do
        [ "$client" != "$current" ] && tmux detach-client -t "$client"
    done
}

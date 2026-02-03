# open yadm files with lazygit
alias lazyyadm='lazygit --use-config-file "${HOME}/.config/yadm/lazygit.yml,${HOME}/.config/lazygit/config.yml" --work-tree "${HOME}" --git-dir "${HOME}/.local/share/yadm/repo.git"'

# lazygit aliases
alias ly='lazyyadm'
alias lg='lazygit'

# neovim
alias v='nvim'

# defaults for standard commands
alias mkdir='mkdir -pv'
alias less='less -FSRXc'

# use modern alternatives
alias ls='eza'
alias ll='eza -la --header --git --icons --changed --time-style=iso'

# only use interactive flags and modern alternatives in terminals
if [[ -t 1 ]]; then
    alias cp='cp -iv'
    alias mv='mv -iv'
    alias cat='bat'
    alias cd='z'
fi

# Opens current directory in MacOS Finder
alias f='open -a Finder ./'

# git repo line count
alias git-count='git ls-files | xargs wc -l'

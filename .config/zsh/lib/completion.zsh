# Add completion directories to fpath
fpath=(
    "${HOME}/.config/zsh/completions"
    "${fpath[@]}"
)

# Initialize completion system — full rebuild once per day, skip security check otherwise
# https://scottspence.com/posts/speeding-up-my-zsh-shell
autoload -Uz compinit
# Glob must expand outside [[ ]] (zsh won't do filename generation inside it)
local -a _zcompdump_stale=( ${HOME}/.zcompdump(Nmh+24) )
if [[ ! -f "${HOME}/.zcompdump" ]] || (( ${#_zcompdump_stale} )); then
    compinit
else
    compinit -C
fi
unset _zcompdump_stale

# Bash completions compatibility
autoload -U bashcompinit
bashcompinit

# AWS (uses bash complete, not zsh fpath)
command -v aws_completer &>/dev/null && complete -C "$(command -v aws_completer)" aws

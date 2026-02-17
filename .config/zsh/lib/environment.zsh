# Language
export LANG=en_US.UTF-8

# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# Neovim
export NVIM_APPNAME="lazyvim"

# Editor
if command -v nvim &>/dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

# Starship
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"

# Virtualenv prompt (starship handles this)
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Claude Code
export ENABLE_TOOL_SEARCH=true
export ENABLE_EXPERIMENTAL_MCP_CLI=false

# Man pages with bat/batcat when available
if command -v bat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif command -v batcat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi

# https://superuser.com/a/1447349
unset LESS

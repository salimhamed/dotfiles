# manually set language environment
export LANG=en_US.UTF-8

# Manage path
export PATH="${HOME}/go/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:${PATH}"

# add JetBrains Toolbox scripts to path
if [ -d "${HOME}/Library/Application Support/JetBrains/Toolbox" ]; then
    export PATH="${PATH}:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Define custom location for configuration files
export XDG_CONFIG_HOME="$HOME/.config"

# Define preferred editor
if command -v nvim &>/dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

# setup pyenv

# pyenv is installed with homebrew, so homebrew must be setup first
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# setup pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# define custom path for starship configuration
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# disable theme because prompt is managed by starship
# shellcheck disable=SC2034
ZSH_THEME=""

# define custom folder (default is `$ZSH/custom`)
ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"

# source secrets
# shellcheck source=/dev/null
[ -f ~/.secrets.sh ] && . ~/.secrets.sh

# source work helpers
# shellcheck source=/dev/null
[ -f ~/.work.zsh ] && . ~/.work.zsh

# Specify oh-my-zsh plugins
# shellcheck disable=SC2034
plugins=(
    # order matters!
    aws
    git
    cp
    history
    docker
    nvm
    npm
    colorize
    colored-man-pages
    copypath
    web-search
    jump
    pyenv
    gh
    zsh-autosuggestions
    zsh-syntax-highlighting
    vi-mode
    fzf
    fd
    pip
    zoxide
    starship
)

# Define directories for "function search path", which contain files
# that can be marked to be loaded automatically when the function they
# contain is needed for the first time.
# See https://unix.stackexchange.com/a/33898/521611 for more info on $fpath
fpath_dirs=(
    "${ZSH_CUSTOM}/plugins/zsh-completions/src"
    "${ZSH_CUSTOM}/completions"
)

# conditionally add brew
if command -v brew &>/dev/null; then
    fpath_dirs+=("$(brew --prefix)/share/zsh/site-functions")
fi

# append to fpath
fpath=("${fpath_dirs[@]}" "${fpath[@]}")

# install oh-my-zsh
# this will call `compinit` to initialize the zsh completion system
# shellcheck source=/dev/null
source "${ZSH}/oh-my-zsh.sh"

# https://superuser.com/a/1447349
unset LESS

# load bash completion compatibility layer
autoload -U bashcompinit
bashcompinit

# configure auto completion for pipx
eval "$(register-python-argcomplete pipx)"

# configure auto completion for pipenv
eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Homebrew and mise live in .zshenv (not .zprofile) so they're available in
# all shell types, including non-interactive SSH sessions (e.g. mosh-server).
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v mise &>/dev/null; then
    eval "$(mise activate zsh --shims)"
fi

# Skip Ubuntu's /etc/zsh/zshrc compinit — we run our own in completion.zsh
skip_global_compinit=1

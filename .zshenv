[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Skip Ubuntu's /etc/zsh/zshrc compinit — we run our own in completion.zsh
skip_global_compinit=1

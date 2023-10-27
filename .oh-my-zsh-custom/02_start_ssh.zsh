# Start SSH agent
if [ ! -S "${HOME}/.ssh/ssh_auth_sock" ]; then
    eval "$(ssh-agent -s)"
    ln -sf "$SSH_AUTH_SOCK" "${HOME}/.ssh/ssh_auth_sock"
fi
export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
ssh-add -l >/dev/null || ssh-add
